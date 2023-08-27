import os
import sys
import time
import subprocess
import threading
import shutil
import fnmatch
import re
from plugins.EdkPlugins.edk2.model import dsc,dec,inf

# This pool is used for caching DEC objects in order to circumvent repetitive instantiations.
dec_pool:dict[str,dec.DECFile]=dict()

def load_dec(file_path:str)->tuple[dec.DECFile,bool]:
	if file_path in dec_pool:
		return dec_pool[file_path],True
	dec_file=dec.DECFile(file_path)
	parse_ret=dec_file.Parse()
	if parse_ret:
		dec_pool[file_path]=dec_file
	return dec_file,parse_ret

class intermediate_object:
	# Intermediate Object should produce ".obj" or ".res" file finally.
	def __init__(self,file_name:str,parent,optimize:bool=False,name=None)->None:
		self.file_name=file_name
		if name is None:
			tmp=os.path.split(file_name)[-1].split('.')
			tmp.pop()
			self.name=""
			for t in tmp:
				self.name+=t
		else:
			self.name=name
		self.parent:library_object=parent
		self.optimize=optimize
		self.proc:subprocess.Popen=None

	def to_cmd(self)->list[str]:
		bin_path=os.path.join(".",self.parent.output_base,"comp{}_uefix64".format("fre" if self.optimize else "chk"))
		obj_path=os.path.join(bin_path,"Intermediate",self.parent.name)
		args:list[str]=[]
		if self.file_name.endswith('.c'):
			no_ext=self.file_name.split(os.sep)[-1][:-2]
			# C Source File.
			args+=["cl",self.file_name]
			# Include Files
			for inc in self.parent.includes:
				args.append("/I"+inc)
			args.append("/I."+os.sep)
			args.append("/I.{}{}".format(os.sep,self.parent.dir_base))
			for inc in self.parent.force_includes:
				args.append("/FI"+inc)
			# General Flags
			args+=["/Zi","/nologo","/W3","/wd4244","/WX"]
			# Optimizer Flags
			args+=["/O2" if self.optimize else "/Od"]
			# Extra Flags
			args+=self.parent.extra_cc_flags
			# Output Flags
			args+=["/FAcs","/FS"]
			args.append("/Fa"+os.path.join(obj_path,no_ext+".cod"))
			args.append("/Fo"+os.path.join(obj_path,no_ext+".obj"))
			args.append("/Fd"+os.path.join(obj_path,"vc143.pdb"))
			# Miscellaneous
			args+=["/GS-","/Gr","/TC","/utf-8","/c"]
		elif self.file_name.endswith('.nasm'):
			no_ext=self.file_name.split(os.sep)[-1][:-5]
			# Netwide Assembly Source File
			args+=["nasm",self.file_name,"-fwin64"]
			# Output
			args+=["-o",os.path.join(obj_path,no_ext+".obj")]
			args+=["-l",os.path.join(obj_path,no_ext+".lst")]
			# Include Files
			for inc in self.parent.includes:
				args.append("-I"+inc)
			args.append("-P"+os.path.join(".","MdePkg","pcdhack.nasm"))
		else:
			print("[Error] Unknown File Extension! File Name: "+self.file_name)
		return args
	
	def build(self)->None:
		args=self.to_cmd()
		self.proc=subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

	def wait(self)->int:
		stdout_bytes:bytes
		stderr_bytes:bytes
		print(self.to_cmd())
		stdout_bytes,stderr_bytes=self.proc.communicate()
		if len(stdout_bytes):
			stdout_text=stdout_bytes.decode()
			self.parent.log_print("[Build - StdOut] Unit {}\n{}".format(self.name,stdout_text),end='')
		if len(stderr_bytes):
			stderr_text=stderr_bytes.decode()
			self.parent.log_print("[Build - StdErr] Unit {}\n{}".format(self.name,stderr_text),end='')
		return self.proc.returncode

class library_object:
	# Library Object should produce ".lib" file finally.
	def __init__(self,name:str)->None:
		self.name=name
		self.dir_base:str=""
		self.files:list[str]=[]
		self.includes:list[str]=[]
		self.force_includes:list[str]=[]
		self.extra_cc_flags:list[str]=[]
		self.intermediates:list[intermediate_object]=[]
		self.thread:threading.Thread=None
		self.optimize:bool=False
		self.output_base:str=""
		self.log:str=""
		self.log_lock:threading.Lock=threading.Lock()

	@classmethod
	def from_inf(self,inf_file:inf.INFFile):
		base_name=os.path.split(inf_file.GetFilename())[-1][:-4]
		lib_obj=library_object(base_name)
		print("Module Name: {} Type: {}".format(base_name,inf_file.GetDefine("MODULE_TYPE")))
		lib_obj.dir_base=inf_file.GetModuleRootPath()
		# Source Objects
		src_list:list[inf.INFSourceObject]=inf_file.GetSourceObjects()
		for src in src_list:
			arch=src.GetArch()
			family=src.GetFamily()
			if (arch=="common" or arch=="X64") and (family is None or family=="MSFT"):
				src_fn:str=src.GetSourceFullPath()
				predef_key_list:list[str]=re.findall(r'\$\(.*?\)',src_fn)
				for key in predef_key_list:
					keyword="DEFINE "+key[2:-1]
					definition:str=inf_file.GetDefine(keyword)
					print("Replacing {} with {}".format(key,definition))
					src_fn=src_fn.replace(key,definition)
				lib_obj.add_file(src_fn)
		# Extra Compiler Options
		build_options:list[inf.INFSection]=inf_file.GetSectionByName("BuildOptions")
		for b_opt in build_options:
			b_objs:list[inf.INFSectionObject]=b_opt.GetObjects()
			for b_obj in b_objs:
				# EDK2 didn't provide interface to parse the build-option expressions.
				# So manually analyze the expression.
				b_ln:int=b_obj.GetStartLinenumber()
				b_str:str=b_opt.GetLine(b_ln)
				def_ln=b_str.split('=')
				def_l=def_ln[0].strip()
				def_r=def_ln[1].strip()
				def_flags=def_r.split()
				print("Left: {}, Right: {}".format(def_l,def_r))
				# The left would specify a target triplet and compiler provider.
				def_l_ln=def_l.split(":")
				def_l_triplet:str=def_l
				def_cc="Any"
				# Check if compiler provider is specified
				if len(def_l_ln)==2:
					def_l_triplet=def_l_ln[1].strip()
					def_cc=def_l_ln[0].strip()
				if def_cc=="Any" or def_cc=="MSFT":
					if fnmatch.fnmatch("*_*_X64_CC_FLAGS",def_l_triplet):
						print("Adding compiler flags: {}".format(def_flags))
						lib_obj.extra_cc_flags+=def_flags
		# Include Headers
		pkg_list:list[inf.INFDependentPackageObject]=inf_file.GetSectionObjectsByName("Packages")
		for pkg in pkg_list:
			path=os.path.join("edk2",pkg.GetPath()).replace('/',os.sep)
			dec_file,ret=load_dec(path)
			if not ret:
				print("Failed to load DEC file! (Unit: {}, Path: {})".format(lib_obj.name,path))
				return None
			inc_list:list[dec.DECIncludeObject]=dec_file.GetSectionObjectsByName("Includes")
			for inc in inc_list:
				arch:str=inc.GetArch()
				if arch=="common" or arch=="X64":
					path=os.path.join("edk2",dec_file.GetBaseName(),inc.GetPath()).replace('/',os.sep)
					lib_obj.includes.append(path)
		# Force Includes
		lib_obj.force_includes.append(os.path.join('.',dec_file.GetBaseName()+"_pcdhack.h"))
		return lib_obj

	def log_print(self,text:str,end='\n')->None:
		self.log_lock.acquire(True)
		self.log+=text+end
		self.log_lock.release()

	def add_file(self,file_name:str)->None:
		self.files.append(file_name)
	
	def add_files(self,file_names:list[str])->None:
		self.files+=file_names

	def to_cmd(self)->list[str]:
		bin_path=os.path.join(".",self.output_base,"comp{}_uefix64".format("fre" if self.optimize else "chk"))
		obj_path=os.path.join(bin_path,"Intermediate",self.name)
		args:list[str]=["lib",os.path.join(obj_path,"*.obj"),"/MACHINE:X64","/NOLOGO"]
		args.append("/OUT:{}.lib".format(os.path.join(bin_path,self.name)))
		return args
	
	def thread_rt(self)->None:
		# Start compilation for all intermediate objects within the library
		for fn in self.files:
			intm=intermediate_object(fn,self,self.optimize)
			if len(intm.to_cmd()):
				self.intermediates.append(intm)
				intm.build()
		# Now wait for all intermediate objects to be compiled
		for intm in self.intermediates:
			ret=intm.wait()
			self.log_print("[Info - {}] Intermediate Object {} returned code {}".format(self.name,intm.name,ret))
		# Next, call the linker
		args=self.to_cmd()
		proc=subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
		stdout_bytes:bytes
		stderr_bytes:bytes
		stdout_bytes,stderr_bytes=proc.communicate()
		if len(stdout_bytes):
			stdout_text=stdout_bytes.decode()
			self.log_print("[Build - StdOut] Unit {}\n{}".format(self.name,stdout_text),end='')
		if len(stderr_bytes):
			stderr_text=stderr_bytes.decode()
			self.log_print("[Build - StdErr] Unit {}\n{}".format(self.name,stderr_text),end='')
		self.log_print("[Info - {}] Linker returned code {}".format(self.name,proc.returncode))

	def build(self)->None:
		print("Building {}...".format(self.name))
		# Start a thread to compile the library.
		self.thread=threading.Thread(target=self.thread_rt)
		self.thread.start()

	def wait(self)->int:
		self.thread.join()
		self.log_lock.acquire(True)
		print(self.log,end='')
		self.log=""
		self.log_lock.release()

class package_object:
	# Package Object does not produce any files itself, but monitors the entire pipeline for building the package.
	def __init__(self,dsc_file:dsc.DSCFile,dec_file:dec.DECFile):
		self.name=dec_file.GetDefine("PACKAGE_NAME")
		self.libs:list[library_object]=[]
		# Enumerate the components
		sect_list:list[dsc.DSCSection]=dsc_file.GetSectionByName("Components")
		for sect in sect_list:
			arch=sect.GetArch()
			if arch=="common" or arch=="X64":
				comp_list:list[dsc.DSCComponentObject]=sect.GetObjects()
				for comp in comp_list:
					inf_fn:str=comp.GetFilename()
					inf_fn=inf_fn.replace('/',os.sep)
					inf_fn=os.path.join(".","edk2",inf_fn)
					inf_file=inf.INFFile(inf_fn)
					if not inf_file.Parse():
						print("[Error] Failed to parse inf file: {}".format(inf_fn))
						continue
					lib_obj=library_object.from_inf(inf_file)
					lib_obj.output_base=os.path.join("bin",self.name)
					self.libs.append(lib_obj)
	
	def build(self):
		for lib_obj in self.libs:
			lib_obj.build()
		for lib_obj in self.libs:
			lib_obj.wait()

def make_basetools():
	pass

def create_pcd_header(package_dec:dec.DECFile,output_file:str)->None:
	fd=open(output_file,'w')
	fd.write("// Generated PCD Constant Header\n\n")
	fd.write("#include <Uefi.h>\n")
	fd.write("#include <PiDxe.h>\n")
	fd.write("#include <Library/PcdLib.h>\n\n")
	fd.write("extern CHAR8* gEfiCallerBaseName;\n")
	fd.write("extern EFI_GUID gEfiCallerIdGuid;\n")
	fd.write("extern EFI_GUID gTianoCoreCustomDecompressGuid;\n")
	pcd_sects:list[dec.DECSection]=package_dec.GetSectionByName("Pcds")
	# Use a set to prevent repeat enumeration.
	processed_pcds=set()
	for pcd_sect in pcd_sects:
		pcds:list[dec.DECPcdObject]=pcd_sect.GetObjects()
		for pcd in pcds:
			if not pcd.GetStartLinenumber() in processed_pcds:
				pcd_type:str=pcd.GetPcdDataType()
				if pcd_type.endswith('*'):
					pcd_type="PTR"
				elif pcd_type.startswith('UINT'):
					pcd_type=pcd_type[4:]
				elif pcd_type=="BOOLEAN":
					pcd_type="BOOL"
				fd.write("#define _PCD_GET_MODE_{}_{} \t {}\n".format(pcd_type,pcd.GetName(),pcd.GetPcdValue()))
				processed_pcds.add(pcd.GetStartLinenumber())
	fd.close()

def create_guid_source(package_dec:dec.DECFile,output_file:str)->library_object:
	fd=open(output_file,'w')
	fd.write("// Generated GUID Source File\n\n")
	guid_sects:list[dec.DECSection]=package_dec.GetSectionByName("Guids")+package_dec.GetSectionByName("Protocols")+package_dec.GetSectionByName("Ppis")
	for guid_sect in guid_sects:
		guid_arch:str=guid_sect.GetArch()
		if guid_arch=="common" or guid_arch=="X64":
			guids:list[dec.DECGuidObject]=guid_sect.GetObjects()
			for guid in guids:
				fd.write("EFI_GUID {}={};\n".format(guid.GetName(),guid.GetGuid()))
	fd.close()
	pkg_name=package_dec.GetBaseName()
	lib_obj=library_object(pkg_name+"Guids")
	lib_obj.add_file(output_file)
	return lib_obj

def build_prep(dsc_file:dsc.DSCFile,module_name:str)->None:
	sect_list:list[dsc.DSCSection]=dsc_file.GetSectionByName("Components")
	for sect in sect_list:
		arch=sect.GetArch()
		if arch=="common" or arch=="X64":
			comp_list:list[dsc.DSCComponentObject]=sect.GetObjects()
			for comp in comp_list:
				inf_fn:str=comp.GetFilename()
				inf_fn=inf_fn.replace('/',os.sep)
				inf_fn=os.path.join(".","edk2",inf_fn)
				inf_file=inf.INFFile(inf_fn)
				if not inf_file.Parse():
					print("[Error] Failed to parse inf file: {}".format(inf_fn))
					continue
				mod_dn:str=inf_fn.split(os.sep)[-1][:-4]
				print("Preparing module {}...".format(mod_dn))
				try:
					os.makedirs(os.path.join("bin",module_name,"compchk_uefix64","Intermediate",mod_dn))
				except:
					pass
				try:
					os.makedirs(os.path.join("bin",module_name,"compfre_uefix64","Intermediate",mod_dn))
				except:
					pass

def build_library(lib_obj:library_object,optimize:bool,output_base:str)->None:
	print(lib_obj.name)
	print(lib_obj.build())

if __name__=="__main__":
	dir_path=os.path.join(".","edk2",sys.argv[2])
	dsc_path=os.path.join(dir_path,sys.argv[3]+".dsc")
	dec_path=os.path.join(dir_path,sys.argv[3]+".dec")
	dsc_file=dsc.DSCFile(dsc_path)
	dec_file=dec.DECFile(dec_path)
	if dsc_file.Parse() and dec_file.Parse():
		print("Number of Sections: "+str(len(dsc_file._sections)))
		dec_pool[dec_file.GetFilename()]=dec_file
		print(dec_pool)
	else:
		print("Failed to parse dsc or dec file!")
		exit(1)
	pkg_repo={'{}/{}.dec'.format(sys.argv[2],sys.argv[3]):dec_file}
	if sys.argv[1]=='prep':
		if sys.argv[2]=='BaseTools':
			print("Compilation for BaseTools is unimplemented!")
		else:
			build_prep(dsc_file,sys.argv[3])
	elif sys.argv[1]=='build':
		t1=time.time()
		preset=sys.argv[4]
		compiler_path=os.path.join("V:","Program Files","Microsoft Visual Studio","2022","BuildTools","VC","Tools","MSVC","14.31.31103","bin","Hostx64","x64")
		optimize=False
		os.environ['PATH']=compiler_path+';'+os.environ['PATH']
		if preset=="Checked" or preset=='Debug':
			optimize=False
		elif preset=="Free" or preset=='Release':
			optimize=True
		else:
			print("Unknown Preset: {}!".format(sys.argv[4]))
		if sys.argv[3]=='BaseTools':
			print("Compilation for BaseTools is unimplemented!")
		else:
			create_pcd_header(dec_file,sys.argv[3]+"_pcdhack.h")
			guid_pkg=create_guid_source(dec_file,sys.argv[3]+'Guid.c')
			output_base=os.path.join("bin",sys.argv[3])
			# Build the GUID package
			build_library(guid_pkg,optimize,output_base)
			copy_dir=os.path.join("edk2","Bin",sys.argv[3])
			# Build the Libraries
			pkg_obj=package_object(dsc_file,dec_file)
			pkg_obj.build()
			# shutil.copytree(output_base,copy_dir,dirs_exist_ok=True)
		t2=time.time()
		print("Compilation Time: {} seconds...".format(t2-t1))
	elif sys.argv[1]=='clean':
		shutil.rmtree(os.path.join("edk2","Bin",sys.argv[2]))
		build_prep(dsc_file,sys.argv[2])
	else:
		print("Unknown command: {}!".format(sys.argv[1]))