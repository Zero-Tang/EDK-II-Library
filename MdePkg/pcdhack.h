/*
  EDK II Library PCD Constant Hacks
*/

#define gEfiCallerBaseName		"NoirVisor"

#define _PCD_GET_MODE_BOOL_PcdVerifyNodeInList			FALSE
#define _PCD_GET_MODE_BOOL_PcdDriverDiagnosticsDisable	FALSE
#define _PCD_GET_MODE_BOOL_PcdDriverDiagnostics2Disable	FALSE
#define _PCD_GET_MODE_BOOL_PcdComponentNameDisable		FALSE
#define _PCD_GET_MODE_BOOL_PcdComponentName2Disable		FALSE
#define _PCD_GET_MODE_BOOL_PcdUgaConsumeSupport			TRUE 

#define _PCD_GET_MODE_8_PcdSpeculationBarrierType		1
#define _PCD_GET_MODE_8_PcdDebugPropertyMask			0
#define _PCD_GET_MODE_8_PcdDebugClearMemoryValue		0xAF

#define _PCD_GET_MODE_32_PcdDebugPrintErrorLevel		0x80000000
#define _PCD_GET_MODE_32_PcdFixedDebugPrintErrorLevel	0xFFFFFFFF
#define _PCD_GET_MODE_32_PcdMaximumLinkedListLength		1000000
#define _PCD_GET_MODE_32_PcdMaximumUnicodeStringLength	1000000
#define _PCD_GET_MODE_32_PcdMaximumAsciiStringLength	1000000
#define _PCD_GET_MODE_32_PcdUefiLibMaxPrintBufferSize	320
#define _PCD_GET_MODE_32_PcdMaximumDevicePathNodeCount	0