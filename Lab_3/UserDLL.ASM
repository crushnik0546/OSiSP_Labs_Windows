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

; 1 - строка заменена
; 0 - строка не была заменена
; BOOL RewriteString(int hProcess, char* findStr, char* newStr)
proc RewriteString uses ebx edi esi,\
     hProcess, findStr, newStr

     locals
       lpSystemInfo     SYSTEM_INFO
       lpMemBasicInfo   MEMORY_BASIC_INFORMATION
     endl

       lea     esi, [lpSystemInfo]
       invoke  GetSystemInfo, esi

      ; cinvoke sprintf, bufferString, formatSysInfo,\
      ;         [lpSystemInfo.dwPageSize], [lpSystemInfo.lpMinimumApplicationAddress], [lpSystemInfo.lpMaximumApplicationAddress]
      ; invoke  MessageBox, HWND_DESKTOP, bufferString, NULL, MB_ICONERROR+MB_OK

       lea     edi, [lpMemBasicInfo]
       mov     eax, sizeof.MEMORY_BASIC_INFORMATION
       invoke  VirtualQueryEx, [hProcess], lpAdress, edi, eax
     ;  cinvoke sprintf, bufferString, formatMemInfo,\
     ;          [lpMemBasicInfo.BaseAddress], [lpMemBasicInfo.AllocationBase],\
     ;          [lpMemBasicInfo.AllocationProtect], dword [lpMemBasicInfo.PartitionId],\
     ;          [lpMemBasicInfo.RegionSize], [lpMemBasicInfo.State],\
     ;          [lpMemBasicInfo.Protect], [lpMemBasicInfo.Type]
     ;  invoke  MessageBox, HWND_DESKTOP, bufferString, NULL, MB_ICONERROR+MB_OK


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
formatSysInfo   db      "dwPageSize %d, lpMinimumApplicationAddress %X, lpMaximumApplicationAddress %X", 0
formatMemInfo   db      "BaseAddress %X, AllocationBase %X, AllocationProtect %X, PartitionId %d, RegionSize %X, State %X, Protect %X, Type %X", 0
lpAdress        dd      0

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
          user32,'USER32.DLL',\
          mscvrt,'msvcrt.DLL'

  import mscvrt,\
         sprintf,'sprintf'

  include "api\kernel32.inc"
  include "api\user32.inc"

section '.edata' export data readable

  export 'ERRORMSG.DLL',\
         ShowErrorMessage,'ShowErrorMessage',\
         ShowLastError,'ShowLastError',\
         RewriteString,'RewriteString'

section '.reloc' fixups data readable discardable
