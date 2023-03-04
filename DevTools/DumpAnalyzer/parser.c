#include <Uefi.h>
#include <Guid/DebugImageInfoTable.h>
#include <Library/BaseMemoryLib.h>
#include <Library/PrintLib.h>
#include "parser.h"

BOOLEAN CompareGuid(IN CONST GUID *Guid1,IN CONST GUID *Guid2)
{
	INT32 *g1=(INT32*)Guid1;
	INT32 *g2=(INT32*)Guid2;
	// Compare 32 bits at a time
	INT32 r=g1[0]-g2[0];
	r|=g1[1]-g2[1];
	r|=g1[2]-g2[2];
	r|=g1[3]-g2[3];
	return r==0;
}

void GetDevicePathString(IN UINT64 DevicePathPointer,OUT CHAR16 *String,IN UINTN Size)
{
	EFI_DEVICE_PATH_PROTOCOL DevPath;
	ReadDumpMemory(DevicePathPointer,&DevPath,sizeof(DevPath),NULL);
	UINT16 DevPathLen=*(UINT16*)DevPath.Length;
	if(DevPath.Type==MEDIA_DEVICE_PATH)
	{
		if(DevPath.SubType==MEDIA_FILEPATH_DP)
		{
			ReadDumpMemory(DevicePathPointer+sizeof(DevPath),String,DevPathLen-sizeof(DevPath),NULL);
			GetDevicePathString(DevicePathPointer+DevPathLen,&String[(DevPathLen>>1)-2],Size-DevPathLen);
		}
		else if(DevPath.SubType==MEDIA_PIWG_FW_FILE_DP)
		{
			EFI_GUID PiwgGuid;
			ReadDumpMemory(DevicePathPointer+sizeof(DevPath),&PiwgGuid,sizeof(PiwgGuid),NULL);
			UnicodeSPrint(String,Size,L"PIWG\\{%08X-%04X-%04X-%02X%02X%02X%02X%02X%02X%02X%02X%02X}",PiwgGuid.Data1,PiwgGuid.Data2,PiwgGuid.Data3,PiwgGuid.Data4[0],PiwgGuid.Data4[1],PiwgGuid.Data4[2],PiwgGuid.Data4[3],PiwgGuid.Data4[4],PiwgGuid.Data4[5],PiwgGuid.Data4[6],PiwgGuid.Data4[7]);
		}
	}
	else if(DevPath.Type==END_DEVICE_PATH_TYPE)
		*String=L'\0';
	else
	{
		ConsolePrintfA("Unknown Device-Path Type: 0x%02X, SubType: 0x%02X!\n",DevPath.Type,DevPath.SubType);
	}
}

void EnumerateImages()
{
	BOOLEAN FoundSystemTablePointer=FALSE;
	for(UINT64 Address=0;Address<DumpFileSize;Address+=0x400000)
	{
		EFI_SYSTEM_TABLE_POINTER SysTablePtr;
		ReadDumpMemory(Address,&SysTablePtr,sizeof(SysTablePtr),NULL);
		if(SysTablePtr.Signature==EFI_SYSTEM_TABLE_SIGNATURE)
		{
			EFI_SYSTEM_TABLE SystemTable;
			EFI_CONFIGURATION_TABLE *ConfigTables;
			UINTN ConfigTableSize;
			ReadDumpMemory(SysTablePtr.EfiSystemTableBase,&SystemTable,sizeof(SystemTable),NULL);
			ConfigTableSize=sizeof(EFI_CONFIGURATION_TABLE)*SystemTable.NumberOfTableEntries;
			ConfigTables=MemAlloc(ConfigTableSize);
			if(ConfigTables)
			{
				BOOLEAN FoundConfigTable=FALSE;
				ReadDumpMemory((UINT64)SystemTable.ConfigurationTable,ConfigTables,(UINT32)ConfigTableSize,NULL);
				for(UINTN i=0;i<SystemTable.NumberOfTableEntries;i++)
				{
					if(CompareGuid(&ConfigTables[i].VendorGuid,&gEfiDebugImageInfoTableGuid))
					{
						EFI_DEBUG_IMAGE_INFO_TABLE_HEADER InfoHeader;
						EFI_DEBUG_IMAGE_INFO *ImageTable;
						UINT32 ImageTableSize;
						ReadDumpMemory((UINT64)ConfigTables[i].VendorTable,&InfoHeader,sizeof(InfoHeader),NULL);
						ConsolePrintfA("Number of Images: %u\n",InfoHeader.TableSize);
						ImageTableSize=sizeof(EFI_DEBUG_IMAGE_INFO)*InfoHeader.TableSize;
						ImageTable=MemAlloc(ImageTableSize);
						if(ImageTable)
						{
							ReadDumpMemory((UINT64)InfoHeader.EfiDebugImageInfoTable,ImageTable,ImageTableSize,NULL);
							for(UINT32 j=0;j<InfoHeader.TableSize;j++)
							{
								EFI_DEBUG_IMAGE_INFO_NORMAL ImageInfo;
								ReadDumpMemory((UINT64)ImageTable[j].NormalImage,&ImageInfo,sizeof(ImageInfo),NULL);
								if(ImageInfo.ImageInfoType==EFI_DEBUG_IMAGE_INFO_TYPE_NORMAL)
								{
									EFI_LOADED_IMAGE_PROTOCOL LoadedImage;
									CHAR16 DevicePath[256];
									ReadDumpMemory((UINT64)ImageInfo.LoadedImageProtocolInstance,&LoadedImage,sizeof(LoadedImage),NULL);
									GetDevicePathString((UINT64)LoadedImage.FilePath,DevicePath,sizeof(DevicePath));
									ConsolePrintfA("Handle: 0x%llX\t Base: 0x%016llX\t Size: 0x%08llX\t Path: %ws\n",ImageInfo.ImageHandle,LoadedImage.ImageBase,LoadedImage.ImageSize,DevicePath);
								}
							}
							MemFree(ImageTable);
						}
						FoundConfigTable=TRUE;
						break;
					}
				}
				if(!FoundConfigTable)ConsolePrintfA("Failed to locate EFI_DEBUG_IMAGE_INFO_TABLE_HEADER!\n");
				MemFree(ConfigTables);
			}
			FoundSystemTablePointer=TRUE;
		}
	}
	if(!FoundSystemTablePointer)ConsolePrintfA("Failed to locate EFI_SYSTEM_TABLE_POINTER!\n");
}