format PE Console 4.0
entry start

include 'win32a.inc'

section '.text' code readable executable

  start:
       ; invoke  GetStdHandle, STD_OUTPUT_HANDLE
       ; mov     [stdout], eax
       ; invoke  GetStdHandle, STD_INPUT_HANDLE
      ;  mov     [stdin], eax

      ;  invoke  SetLastError,0
      ;  invoke  ShowLastError, HWND_DESKTOP
        invoke  GetCurrentProcess
        invoke  RewriteString, eax, 0, 0

       ; invoke  WriteConsole, [stdout], consoleMsg, 5, NULL, NULL
       ; invoke  ReadConsole, [stdin], lpBuffer, 1, lpCharsRead, NULL
  exit:
        invoke  ExitProcess, 0

       ; invoke  SetLastError,0
       ; invoke  ShowLastError,HWND_DESKTOP
        ;invoke  ExitProcess,0

section '.data' data readable writeable

consoleMsg      db      'Hello', 0
lpBuffer        db      10 dup (0)
lpCharsRead     dd      ?
stdin           dd      ?
stdout          dd      ?

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
          userDll,'UserDLL.DLL'

  import userDll,\
         ShowLastError,'ShowLastError',\
         RewriteString,'RewriteString'

  include "api\kernel32.inc"
