struct MEMORY_BASIC_INFORMATION
  BaseAddress         dd ?    ; PVOID
  AllocationBase      dd ?    ; PVOID
  AllocationProtect   dd ?    ; DWORD
 ; PartitionId         dw ?    ; WORD
  RegionSize          dd ?    ; SIZE_T
  State               dd ?    ; DWORD
  Protect             dd ?    ; DWORD
  Type                dd ?    ; DWORD
ends