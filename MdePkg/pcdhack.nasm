%define ASM_PFX(a) a

%define PcdGet32(a) _gPcd_FixedAtBuild_ %+ a

%define THUNK_ATTRIBUTE_DISABLE_A20_MASK_INT_15   0x00000002
%define THUNK_ATTRIBUTE_DISABLE_A20_MASK_KBD_CTRL 0x00000004