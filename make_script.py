import os
import sys
import time
import subprocess

def parse_inf(inf_path):
	# Read the file.
	fd=open(inf_path)
	lines=[l for l in fd]
	line_count=len(lines)
	fd.close()
	# Parse.
	processing_sources=False
	processing_defines=False
	processing_packages=False
	processing_libclass=False
	processing_pcds=False
	src_list=[]
	def_dict={}
	pak_list=[]
	pcd_list=[]
	libcls_list=[]
	i=0
	while i<line_count:
		# Strip the line.
		cur_line=lines[i].strip()
		# Ignore blank lines...
		if cur_line=='':
			i+=1
			continue
		# Ignore comments...
		if cur_line[0]!='#':
			if cur_line[0]=='[' and cur_line[-1]==']':
				if cur_line=='[Defines]':
					processing_defines=True
					processing_sources=False
					processing_packages=False
					processing_libclass=False
					processing_pcds=False
				elif cur_line=='[Sources]' or cur_line=='[Sources.X64]' or cur_line=='[Sources.common]':
					processing_sources=True
					processing_defines=False
					processing_packages=False
					processing_libclass=False
					processing_pcds=False
				elif cur_line=='[Packages]':
					processing_packages=True
					processing_sources=False
					processing_defines=False
					processing_libclass=False
					processing_pcds=False
				elif cur_line=='[LibraryClasses]' or cur_line=='[LibraryClasses.X64]':
					processing_libclass=True
					processing_packages=False
					processing_sources=False
					processing_defines=False
					processing_pcds=False
				elif cur_line=='[Pcd]':
					processing_pcds=True
					processing_libclass=False
					processing_packages=False
					processing_sources=False
					processing_defines=False
				else:
					processing_libclass=False
					processing_packages=False
					processing_sources=False
					processing_defines=False
					processing_pcds=False
			elif processing_sources:
				statement=cur_line.split("|")
				file=statement[0].strip()
				comp="MSFT"
				if len(statement)==2:
					comp=statement[1].strip()
				if comp=="MSFT":
					src_list.append(file.replace('/',os.sep))
			elif processing_defines:
				statement=cur_line.split("=")
				def_dict[statement[0].strip()]=statement[1].strip()
			elif processing_packages:
				package=cur_line.replace('/',os.sep)
				pak_list.append(package)
			elif processing_pcds:
				pcd_name=cur_line.split('#')[0].strip()
				pcd_list.append(pcd_name)
		i+=1
	# Return
	ret_dict={}
	ret_dict["sources"]=src_list
	ret_dict["defines"]=def_dict
	ret_dict["packages"]=pak_list
	ret_dict["pcds"]=pcd_list
	path_elem=inf_path.split(os.sep)[:-1]
	path_base=""
	for p in path_elem:
		path_base=os.path.join(path_base,p)
	ret_dict["path_base"]=path_base
	return ret_dict

def parse_dsc(dsc_path):
	# Read the file.
	fd=open(dsc_path)
	lines=[l for l in fd]
	line_count=len(lines)
	fd.close()
	# Parse.
	processing_components=False
	inf_list=[]
	i=0
	while i<line_count:
		# Strip the line.
		cur_line=lines[i].strip()
		# Ignore blank lines...
		if cur_line=='':
			i+=1
			continue
		if cur_line[0]!='#':
			if cur_line[0]=='[' and cur_line[-1]==']':
				class_statement=cur_line[1:-1]
				classes=[x.strip() for x in class_statement.split(',')]
				if 'Components' in classes or "Components.X64" in classes:
					processing_components=True
				else:
					processing_components=False
			elif processing_components:
				p=cur_line.replace('/',os.sep)
				path=os.path.join(".","edk2",p)
				inf_list.append(path)
		i+=1
	# Return
	ret_dict={}
	ret_dict['components']=inf_list
	return ret_dict

def parse_dec(dec_path):
	elements=dec_path.split(os.sep)
	# Read the file.
	fd=open(dec_path)
	lines=[l for l in fd]
	line_count=len(lines)
	fd.close()
	# Parse.
	processing_defines=False
	processing_includes=False
	processing_pcds_fixed=False
	inc_list=[]
	pcd_dict={}
	i=0
	while i<line_count:
		# Strip the line.
		cur_line=lines[i].strip()
		# Ignore blank lines...
		if cur_line=='':
			i+=1
			continue
		if cur_line[0]!='#':
			if cur_line[0]=='[' and cur_line[-1]==']':
				class_statement=cur_line[1:-1]
				classes=[x.strip() for x in class_statement.split(',')]
				if 'Includes' in classes or 'Includes.X64' in classes:
					processing_includes=True
					processing_defines=False
					processing_pcds_fixed=False
				elif 'PcdsFixedAtBuild' in classes or 'PcdsFeatureFlag' in classes:
					processing_pcds_fixed=True
					processing_includes=False
					processing_defines=False
				else:
					processing_includes=False
					processing_defines=False
					processing_pcds_fixed=False
			elif processing_includes:
				p=cur_line.replace('/',os.sep)
				path=os.path.join(".","edk2",elements[2],p)
				inc_list.append(path)
			elif processing_pcds_fixed:
				pcd_info=cur_line.split('|')
				pcd_dict[pcd_info[0]]=pcd_info[1:]
		i+=1
	# Return
	ret_dict={}
	ret_dict['includes']=inc_list
	ret_dict['pcds']=pcd_dict
	return ret_dict

def create_pcd_header(package_dec,output_file):
	pcds=package_dec['pcds']
	fd=open(output_file,'w')
	fd.write("// Generated PCD Constant File\n\n")
	fd.write('#include <Uefi.h>\n')
	fd.write('#include <PiDxe.h>\n')
	fd.write('#include <Library/PcdLib.h>\n\n')
	fd.write('extern CHAR8 *gEfiCallerBaseName;\n')
	fd.write('extern EFI_GUID gEfiCallerIdGuid;\n')
	fd.write('extern EFI_GUID gTianoCustomDecompressGuid;\n')
	for pcd in pcds:
		pcd_info=pcds[pcd]
		pcd_name=pcd.split('.')[1]
		pcd_value=pcd_info[0]
		pcd_type=pcd_info[1]
		if pcd_type=='BOOLEAN':
			pcd_type='BOOL'
		elif pcd_type[:4]=='UINT':
			pcd_type=pcd_type[4:]
		elif pcd_type[-1:]=='*':
			# Currently, pointer types are unsupported.
			continue
		pcd_def="#define _PCD_GET_MODE_{}_{} \t {}\n".format(pcd_type,pcd_name,pcd_value)
		fd.write(pcd_def)
	fd.close()

def build_package(compiler_path,package_inf,optimize,output_base):
	compiler=os.path.join(compiler_path,"cl.exe")
	lib_builder=os.path.join(compiler_path,"lib.exe")
	packages=package_inf["packages"]
	sources=package_inf["sources"]
	defines=package_inf["defines"]
	bin_path=os.path.join(".",output_base,"compfre_uefix64" if optimize else "compchk_uefix64")
	obj_path=os.path.join(bin_path,"Intermediate",defines['BASE_NAME'])
	pkgs=[]
	pcds=package_inf["pcds"]
	# Hack PCD headers
	#fd=open(defines['BASE_NAME']+"_pcdhack.h",'w')
	for pkg in packages:
		# Extract package info.
		pkg_path=os.path.join(".","edk2",pkg)
		pak=parse_dec(pkg_path)
		pkgs.append(pak)
	#for pcd in pcds:
	#	# Extract PCDs
	#	pcd_info=[]
	#	for pkg in pkgs:
	#		pcd_info=pkg["pcds"][pcd]
	#		pcd_name=pcd.split('.')[1]
	#		pcd_value=pcd_info[0]
	#		pcd_type=pcd_info[1]
	#		print("")
	#		if pcd_type=='BOOLEAN':
	#			pcd_type='BOOL'
	#		elif pcd_type[:4]=='UINT':
	#			pcd_type=pcd_type[4:]
	#		pcd_def="#define _PCD_GET_MODE_{}_{} \t {}\n".format(pcd_type,pcd_name,pcd_value)
	#		fd.write(pcd_def)
	#		print(pcd_def,end='')
	#fd.close()
	# Traverse source files...
	for src in sources:
		flags=[]
		src_path=os.path.join(package_inf["path_base"],src)
		if src[-2:]==".c":
			no_ext=src.split(os.sep)[-1][:-2]
			flags=[compiler,src_path]
			# Construct Compiler Flags - Includes
			for pkg in pkgs:
				inc_list=pkg["includes"]
				for inc in inc_list:
					flags.append('/I{}'.format(inc))
			flags.append('/I.{}'.format(os.sep))
			flags.append('/I.'.format(os.sep,package_inf["path_base"]))
			flags.append('/FI{}'.format(os.path.join('.',"MdePkg_pcdhack.h")))
			# Construct Compiler Flags - General
			flags.append('/Zi')
			flags.append('/nologo')
			flags.append('/W3')
			flags.append('/WX')
			# Construct Compiler Flags - Optmization
			flags.append('/O2' if optimize else '/Od')
			flags.append('/Oi')
			# Construct Compiler Flags - Output
			flags.append('/FAcs')
			flags.append('/Fa{}'.format(os.path.join(obj_path,no_ext+'.cod')))
			flags.append('/Fo{}'.format(os.path.join(obj_path,no_ext+'.obj')))
			flags.append('/Fd{}'.format(os.path.join(obj_path,'vc140.pdb')))
			flags.append('/FS')
			# Construct Compiler Flags - Misc
			flags.append('/GS-')
			flags.append('/Gr')
			flags.append('/TC')
			flags.append('/c')
		elif src[-5:]==".nasm":
			no_ext=src.split(os.sep)[-1][:-5]
			flags=['nasm']
			# Construct Assembler Flags - Output
			flags.append("-o")
			flags.append(os.path.join(obj_path,no_ext+'.obj'))
			flags.append("-fwin64")
			flags.append("-l")
			flags.append(os.path.join(obj_path,no_ext+'.lst'))
			# Construct Compiler Flags - Includes
			for pkg in packages:
				pkg_path=os.path.join(".","edk2",pkg)
				pkg_info=parse_dec(pkg_path)
				inc_list=pkg_info["includes"]
				for inc in inc_list:
					flags.append('-I{}'.format(inc))
			# Misc
			flags.append('-P{}'.format(os.path.join(".","MdePkg","pcdhack.nasm")))
			flags.append(src_path)
		elif src[-2:]=='.h':
			# Header file cannot be compiled. Skip it.
			continue
		#print(flags)
		subprocess.call(flags)
	# Link to library
	flags=[lib_builder]
	flags.append(os.path.join(obj_path,'*.obj'))
	flags.append("/MACHINE:X64")
	flags.append("/NOLOGO")
	flags.append("/OUT:{}".format(os.path.join(bin_path,defines['BASE_NAME']+".lib")))
	subprocess.call(flags)

if __name__=="__main__":
	dir_path=os.path.join(".","edk2",sys.argv[2])
	dsc_path=os.path.join(dir_path,sys.argv[3]+".dsc")
	dec_path=os.path.join(dir_path,sys.argv[3]+".dec")
	dsc_info=parse_dsc(dsc_path)
	dec_info=parse_dec(dec_path)
	create_pcd_header(dec_info,sys.argv[3]+"_pcdhack.h")
	if sys.argv[1]=='prep':
		for inf_path in dsc_info['components']:
			inf_info=parse_inf(inf_path)
			try:
				os.makedirs(os.path.join("bin",sys.argv[3],"compchk_uefix64","Intermediate",inf_info["defines"]["BASE_NAME"]))
			except:
				pass
			try:
				os.makedirs(os.path.join("bin",sys.argv[3],"compfre_uefix64","Intermediate",inf_info["defines"]["BASE_NAME"]))
			except:
				pass
	elif sys.argv[1]=='build':
		t1=time.time()
		preset=sys.argv[4]
		compiler_path=os.path.join("V:","Program Files","Microsoft Visual Studio","2022","BuildTools","VC","Tools","MSVC","14.31.31103","bin","Hostx64","x64")
		optimize=False
		if preset=="Checked" or preset=='Debug':
			optimize=False
		elif preset=="Free" or preset=='Release':
			optimize=True
		else:
			print("Unknown Preset: {}!".format(sys.argv[4]))
		output_base=os.path.join("bin",sys.argv[3])
		for inf_path in dsc_info['components']:
			inf_info=parse_inf(inf_path)
			build_package(compiler_path,inf_info,optimize,output_base)
		t2=time.time()
		print("Compilation Time: {} seconds...".format(t2-t1))
	else:
		print("Unknown command: {}!".format(sys.argv[1]))