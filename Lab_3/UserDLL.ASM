format PE GUI 4.0 DLL
entry DllEntryPoint

include 'win32a.inc'
include "winnt.inc"

section '.text' code readable executable

; need functions
; OpenProcess
; GetSystemInfo -> SYSTEM_INFO structure
; ReadProcessMemory
; VirtualQueryEx -> MEMORY_BASIC_INFORMATION
;

proc DllEntryPoint hinstDLL, fdwReason, lpvReserved
        mov     eax,  TRUE
        ret
endp

; BOOL RewriteString(int hProcess, char* findStr, char* newStr)
proc RewriteString uses ebx edi esi,\
     processId, findStr, newStr

     locals
       lpSystemInfo     SYSTEM_INFO
       lpMemBasicInfo   MEMORY_BASIC_INFORMATION
     endl

       invoke  OpenProcess, PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_QUERY_INFORMATION, FALSE, [processId]
       mov     [hProcess], eax

       lea     esi, [lpSystemInfo]
       invoke  GetSystemInfo, esi

      ; cinvoke sprintf, bufferString, formatSysInfo,\
      ;         [lpSystemInfo.dwPageSize], [lpSystemInfo.lpMinimumApplicationAddress], [lpSystemInfo.lpMaximumApplicationAddress]
      ; invoke  MessageBox, HWND_DESKTOP, bufferString, NULL, MB_ICONERROR+MB_OK

       mov     esi, [lpSystemInfo.lpMaximumApplicationAddress]
       mov     eax, [lpSystemInfo.lpMinimumApplicationAddress]
       mov     [lpAddress], eax

.NextAddress:
       lea     edi, [lpMemBasicInfo]
       invoke  VirtualQueryEx, [hProcess], lpAddress, edi, [sizeMemInfo]
      ; cmp     [lpMemBasicInfo.State], MEM_COMMIT
      ; jne     .AddAddress
      ;
       cinvoke sprintf, bufferString, formatMemInfo,\
               [lpMemBasicInfo.BaseAddress], [lpMemBasicInfo.AllocationBase],\
               [lpMemBasicInfo.AllocationProtect],\; dword [lpMemBasicInfo.PartitionId],\
               [lpMemBasicInfo.RegionSize], [lpMemBasicInfo.State],\
               [lpMemBasicInfo.Protect], [lpMemBasicInfo.Type]
       invoke  MessageBox, HWND_DESKTOP, bufferString, NULL, MB_ICONERROR+MB_OK


.AddAddress:
       mov     eax, [lpMemBasicInfo.RegionSize]
     ;  mov     eax, [lpSystemInfo.dwPageSize]
       add     [lpAddress], eax
       cmp     [lpAddress], esi
       jb      .NextAddress

       mov     eax, TRUE
.return:
       ret
endp

; VOID ShowErrorMessage(HWND hWnd,DWORD dwError);

proc ShowErrorMessage hWnd,dwError
  local lpBuffer:DWORD
        lea     eax,[lpBuffer]
        invoke  FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM,0,[dwError],LANG_NEUTRAL,eax,0,0
        invoke  MessageBox,[hWnd],[lpBuffer],NULL,MB_ICONERROR+MB_OK
        invoke  LocalFree,[lpBuffer]
        ret
endp

; VOID ShowLastError(HWND hWnd);

proc ShowLastError hWnd
        invoke  GetLastError
        stdcall ShowErrorMessage,[hWnd],eax
        ret
endp

section '.data' data readable writeable

bufferString    db      255 dup (0)
formatSysInfo   db      "dwPageSize %X, lpMinimumApplicationAddress %X, lpMaximumApplicationAddress %X", 0
formatMemInfo   db      "BaseAddress %X, AllocationBase %X, AllocationProtect %X, RegionSize %X, State %X, Protect %X, Type %X", 0
sizeMemInfo     dd      sizeof.MEMORY_BASIC_INFORMATION
lpAddress       dd      ?
hProcess        dd      ?

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
          user32,'USER32.DLL',\
          mscvrt,'msvcrt.DLL'

  import mscvrt,\
         sprintf,'sprintf'

  include "api\kernel32.inc"
  include "api\user32.inc"

section '.edata' export data readable

  export 'userDLL.DLL',\
         ShowErrorMessage,'ShowErrorMessage',\
         ShowLastError,'ShowLastError',\
         RewriteString,'RewriteString'

section '.reloc' fixups data readable discardable
