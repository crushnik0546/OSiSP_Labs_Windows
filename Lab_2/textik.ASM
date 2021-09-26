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
        invoke  CreateWindowEx, ebx, className, windowName, WS_OVERLAPPEDWINDOW,\
                CW_USEDEFAULT, CW_USEDEFAULT , CW_USEDEFAULT , CW_USEDEFAULT, ebx, ebx, [hInst], ebx

        mov     [hMainWnd], eax
        invoke  ShowWindow, eax, SW_SHOWNORMAL
       ; invoke  UpdateWindow, [hMainWnd]    с этим почему то не прилетает WM_PAINT

        invoke  GetClientRect, [hMainWnd], rect

        invoke  GetDC, ebx
        mov     [hdc], eax

        invoke  GetTextMetricsA, eax, textMetrics

        invoke  CreateCompatibleDC, [hdc]
        mov     [hBackDC], eax
        invoke  CreateCompatibleBitmap, [hdc], 1920, 1080    ; GetSystemMetrics (for screen)
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
        cmp     eax, WM_PAINT
        je      .WMPaint
        cmp     eax, WM_SIZE
        je      .WMSize
        cmp     eax, WM_DESTROY
        je      .WMDestroy

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .ExitWindowProc

.WMSize:
        invoke  GetClientRect, [hMainWnd], rect
        jmp     .returnZero

.WMPaint:
        stdcall Draw

        lea     esi, [ps]
        invoke  BeginPaint, [hWnd], esi
        mov     [hdc], eax

        invoke  BitBlt, [hdc], 0, 0, [rect.right], [rect.bottom], [hBackDC], 0, 0, SRCCOPY
        invoke  EndPaint, [hWnd], esi

        jmp     .returnZero

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

proc Draw

        locals
                cellWidth       dd      ?
                cellHeight      dd      ?
        endl

        xor     edx, edx
        mov     eax, [rect.right]
        div     [ROW_COUNT]
        mov     [cellWidth], eax
        mov     [textRect.right], eax

        xor     edx, edx
        mov     eax, [MAX_LENGTH]                ; cellHeight = (MAX_LENGTH * tmAveCharWidth / cellWidth + 1) * (tmHeight + tmExternalLeading)
        mul     [textMetrics.tmAveCharWidth]
        xor     edx, edx
        div     [cellWidth]
        inc     eax
        xor     edx, edx
        mov     ecx, [textMetrics.tmHeight]
        add     ecx, [textMetrics.tmExternalLeading]
        mul     ecx            ; add tmExternalLeading need
        mov     [cellHeight], eax
        mov     [textRect.bottom], eax


       ; xor     edx, edx
      ;  mov     eax, [rect.bottom]
      ;  div     [LINE_COUNT]
      ;  mov     [cellHeight], eax

        invoke  GetStockObject, BLACK_BRUSH
        invoke  SelectObject, [hBackDC], eax
        invoke  FillRect, [hBackDC], rect, 0

        invoke  GetStockObject, WHITE_PEN
        invoke  SelectObject, [hBackDC], eax



        invoke  Rectangle, [hBackDC], 0, 0, [cellWidth], [cellHeight]

        invoke  DrawText, [hBackDC], text12, -1, textRect, textStyle, NULL

      ;  invoke  StretchBlt, [hBackDC], 0, 0, [rect.right], [rect.bottom], [hBackgroundDC], 0, 0, 1920, 1080, SRCCOPY

.ReturnDraw:
        ret
endp

proc FindMaxLength uses ebx esi edi
        locals
                maxLength       dd      0
        endl



        ret              ; return maxLength
endp

section '.data' data readable writeable

wcex            WNDCLASSEX sizeof.WNDCLASSEX, CS_HREDRAW or CS_VREDRAW, WindowProc, 0, 0,\
                           0, NULL, NULL, 0, NULL, className, 0

textStyle       = DT_CENTER or DT_VCENTER or DT_WORDBREAK

className       db 'Main_window_class', 0
windowName      db 'Durka', 0

text00          db 'Genshin Impact', 0
text01          db 'JOJO Bizzare Adventure', 0
text02          db 'test', 0
text03          db 'Tokyo Ghoul', 0
text10          db '1000 - 7', 0
text11          db 'STMicrocontrollers', 0
text12          db 'The RECT structure defines a rectangle', 0
text13          db 'test', 0
text20          db 'The RECT structure defines a rectangle', 0
text21          db 'The RECT structure defines a rectangle', 0
text22          db 'The RECT structure defines a rectangle', 0
text23          db 'The RECT structure defines a rectangle', 0      ; length = 38 + 1
; DT_WORDBREAK - переносит слова по пробелам
;

textRect        RECT 0, 0, 400, 400

msg             MSG
rect            RECT
textMetrics     TEXTMETRIC
hMainWnd        dd      ?
hInstance       dd      ?
hBackgroundBmp  dd      ?
hPaimondBmp     dd      ?
hBackDC         dd      ?
hBackBMP        dd      ?
hBackgroundDC   dd      ?

ROW_COUNT       dd      4
LINE_COUNT      dd      3
MAX_LENGTH      dd      38
LINE_HEIGHT     db      40
AV_WIDTH        db      5        ; ширина буквы

section '.idata' import data readable writeable

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL"

        include "api\kernel32.inc"
        include "api\user32.inc"
        include "api\gdi32.inc"