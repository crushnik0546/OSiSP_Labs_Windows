format PE GUI 4.0
entry WinMain

        include 'win32a.inc'

section '.code' code readable executable

proc WinMain, hInstance, hPrevInstance, lpCmdLine, nShowCmd

        locals
                hdc     dd      ?
                hInst   dd      ?
        endl

        xor     ebx, ebx
        invoke  LoadCursor, ebx, IDC_ARROW
        mov     [wcex.hCursor], eax
        invoke  GetStockObject, WHITE_BRUSH
        mov     [wcex.hbrBackground], eax

        invoke  GetModuleHandle, ebx
        mov     [hInst], eax

        invoke  RegisterClassEx, wcex
        invoke  CreateWindowEx, ebx, className, windowName, WS_OVERLAPPEDWINDOW,\ ; or WS_POPUP or WS_MAXIMIZE,\
                ebx, ebx , CW_USEDEFAULT , CW_USEDEFAULT, ebx, ebx, [hInst], ebx

        mov     [hMainWnd], eax
        invoke  ShowWindow, eax, SW_SHOWNORMAL
        invoke  UpdateWindow, [hMainWnd]

        invoke  GetClientRect, [hMainWnd], rect

        invoke  GetDC, ebx
        mov     [hdc], eax
        invoke  CreateCompatibleDC, [hdc]
        mov     [hBackDC], eax
        invoke  CreateCompatibleBitmap, [hdc], [rect.right], [rect.bottom]
        mov     [hBackBMP], eax
        invoke  SelectObject, [hBackDC], [hBackBMP]
        invoke  ReleaseDC, ebx, [hdc]

cycle:
        invoke  GetMessage, msg, ebx, ebx, ebx
        cmp     eax, 1
        jb      ExitProgram

        invoke  DispatchMessage, msg
        jmp     cycle

;FailedLoadBitmap:
;        invoke MessageBox, HWND_DESKTOP, windowName, NULL, MB_OK

ExitProgram:
        invoke     ExitProcess, [msg.wParam]

endp

proc WindowProc uses ebx esi edi,\
     hWnd, uMsg, wParam, lParam

        locals
                ps              PAINTSTRUCT
                hdc             dd      ?
        endl

        xor     ebx, ebx

        mov     eax, [uMsg]
      ;  cmp     eax, WM_PAINT
      ;  je      .WMPaint
        cmp     eax, WM_DESTROY
        je      .WMDestroy

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .ExitWindowProc


;.WMPaint:
     ;   stdcall Draw

  ;      lea     esi, [ps]
  ;      invoke  BeginPaint, [hWnd], esi
 ;       mov     [hdc], eax

       ; invoke  BitBlt, [hdc], 0, 0, [rect.right], [rect.bottom], [hBackDC], 0, 0, SRCCOPY
  ;      invoke  EndPaint, [hWnd], esi

  ;      jmp     .returnZero

.WMDestroy:
        invoke  PostQuitMessage, ebx
        jmp     .returnZero

;.Fail:
        ;invoke MessageBox, HWND_DESKTOP, windowName, NULL, MB_OK

.returnZero:
        xor     eax, eax

.ExitWindowProc:
        ret

endp

;proc Draw

;        invoke  StretchBlt, [hBackDC], 0, 0, [rect.right], [rect.bottom], [hBackgroundDC], 0, 0, 1920, 1080, SRCCOPY

;.ReturnDraw:
;        ret
;endp

section '.data' data readable writeable

wcex            WNDCLASSEX sizeof.WNDCLASSEX, CS_HREDRAW or CS_VREDRAW, WindowProc, 0, 0,\
                           0, NULL, NULL, 0, NULL, className, 0
className       db 'Main_window_class', 0
windowName      db 'Save Paimon!', 0
msg             MSG
rect            RECT
hMainWnd        dd      ?
hInstance       dd      ?
hBackgroundBmp  dd      ?
hPaimondBmp     dd      ?
hBackDC         dd      ?
hBackBMP        dd      ?
hBackgroundDC   dd      ?

section '.idata' import data readable writeable

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL"

        include "api\kernel32.inc"
        include "api\user32.inc"
        include "api\gdi32.inc"