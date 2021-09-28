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

        invoke  GetSystemMetrics, SM_CXSCREEN
        push    eax
        invoke  GetSystemMetrics, SM_CYSCREEN
        pop     ecx
        invoke  CreateCompatibleBitmap, [hdc], ecx, eax
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

proc Draw uses ebx esi edi

        locals
                cellWidth       dd      ?
                cellHeight      dd      ?
                cellRect        RECT    ?
        endl

        mov     eax, [textRect.left]
        mov     [cellRect.left], eax
        mov     eax, [textRect.top]
        mov     [cellRect.top], eax
        mov     eax, [textRect.right]
        mov     [cellRect.right], eax
        mov     eax, [textRect.bottom]
        mov     [cellRect.bottom], eax

        xor     edx, edx
        mov     eax, [rect.right]
        div     [ROW_COUNT]
        mov     [cellWidth], eax
        mov     [cellRect.right], eax

        xor     edx, edx
        mov     eax, [MAX_LENGTH]               ; cellHeight = (MAX_LENGTH * tmAveCharWidth / cellWidth + 1) * (tmHeight + tmExternalLeading)
        mul     [textMetrics.tmAveCharWidth]
        xor     edx, edx
        div     [cellWidth]
        inc     eax
        xor     edx, edx
        mov     ecx, [textMetrics.tmHeight]
        add     ecx, [textMetrics.tmExternalLeading]
       ; add     ecx, [textMetrics.tmHeight]
        mul     ecx
        mov     [cellHeight], eax
        mov     [cellRect.bottom], eax

        invoke  GetStockObject, BLACK_BRUSH
        invoke  SelectObject, [hBackDC], eax
        invoke  FillRect, [hBackDC], rect, 0

        invoke  GetStockObject, WHITE_PEN
        invoke  SelectObject, [hBackDC], eax

        lea     esi, [cellRect]
        mov     ecx, [LINE_COUNT]
        mov     edi, allText
.LineLoop:
        push    [cellRect.left]
        push    [cellRect.top]
        push    [cellRect.right]
        push    [cellRect.bottom]

        push    ecx
        mov     ecx, [ROW_COUNT]
.RowLoop:
        push    ecx
        invoke  Rectangle, [hBackDC], [cellRect.left], [cellRect.top], [cellRect.right], [cellRect.bottom]

        invoke  DrawTextEx, [hBackDC], [edi], -1, esi, textStyle, NULL

        add     edi, 4

        mov     eax, [cellWidth]
        add     [cellRect.left], eax
        add     [cellRect.right], eax
        pop     ecx
        loop    .RowLoop
.EndRowLoop:
        pop     ecx
        pop     [cellRect.bottom]
        pop     [cellRect.right]
        pop     [cellRect.top]
        pop     [cellRect.left]

        mov     eax, [cellHeight]
        add     [cellRect.top], eax
        add     [cellRect.bottom], eax

        loop    .LineLoop

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

allText         dd text00, text01, text02, text03,\
                   text10, text11, text12, text12,\
                   text20, text21, text22, text23

; DT_WORDBREAK - переносит слова по пробелам
;

textRect        RECT 0, 0, 400, 400

ROW_COUNT       dd      4
LINE_COUNT      dd      3
MAX_LENGTH      dd      38

msg             MSG
rect            RECT
textMetrics     TEXTMETRIC
;drawTextParams  DRAWTEXTPARAMS sizeof.DRAWTEXTPARAMS, 5, 5, 4, 0
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