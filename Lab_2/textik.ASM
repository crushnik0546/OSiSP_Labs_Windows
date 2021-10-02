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
                cellRect        RECT    0, 0, 0, 0
        endl

        xor     edx, edx                        ; cellWidth = windowWidth/ ROW_COUNT
        mov     eax, [rect.right]
        div     [ROW_COUNT]
        mov     [cellWidth], eax
        mov     [cellRect.right], eax

        xor     edx, edx
        mov     eax, [MAX_LENGTH]               ; cellHeight = (MAX_LENGTH * tmAveCharWidth / cellWidth + 1) * (tmHeight + tmExternalLeading) + 2 * tmAveCharWidth
        mul     [textMetrics.tmAveCharWidth]
        xor     edx, edx
        div     [cellWidth]
        inc     eax
        xor     edx, edx
        mov     ecx, [textMetrics.tmHeight]
        add     ecx, [textMetrics.tmExternalLeading]
        mul     ecx
        add     eax, [textMetrics.tmAveCharWidth]
        add     eax, [textMetrics.tmAveCharWidth]
        mov     [cellHeight], eax
        mov     [cellRect.bottom], eax

        invoke  GetStockObject, BLACK_BRUSH
        invoke  SelectObject, [hBackDC], eax
        invoke  FillRect, [hBackDC], rect, 0

        invoke  GetStockObject, WHITE_PEN
        invoke  SelectObject, [hBackDC], eax

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

        stdcall DrawUserText, [cellRect.left], [cellRect.top], [cellRect.right], [cellRect.bottom], [edi]

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

.ReturnDraw:
        ret
endp

proc DrawUserText left, top, right, bottom, lineAdrr
        locals
                textRect        RECT    0, 0, 0, 0
        endl

        mov     eax, [left]
        add     eax, [textMetrics.tmAveCharWidth]
        mov     [textRect.left], eax
        mov     eax, [top]
        add     eax, [textMetrics.tmAveCharWidth]
        mov     [textRect.top], eax
        mov     eax, [right]
        sub     eax, [textMetrics.tmAveCharWidth]
        mov     [textRect.right], eax
        mov     eax, [bottom]
        sub     eax, [textMetrics.tmAveCharWidth]
        mov     [textRect.bottom], eax

        lea     esi, [textRect]
        invoke  DrawTextEx, [hBackDC], [lineAdrr], -1, esi, textStyle, NULL

        xor     eax, eax
        ret
endp

section '.data' data readable writeable

wcex            WNDCLASSEX sizeof.WNDCLASSEX, CS_HREDRAW or CS_VREDRAW, WindowProc, 0, 0,\
                           0, NULL, NULL, 0, NULL, className, 0

textStyle       = DT_CENTER or DT_WORDBREAK or DT_EDITCONTROL

className       db 'Main_window_class', 0
windowName      db 'Dushnilovka', 0

text00          db 'This document provides a description,', 0
text01          db 'specifications, and design related information on the MPU-9250 MotionTracking device.', 0  ; 85
text02          db 'The average width of characters in the font', 0
text03          db 'HELP', 0
text10          db '1000 - 7', 0
text11          db 'The wingdi.h header defines TEXTMETRIC as an alias', 0
text12          db 'JOJO Bizarre Adventure', 0
text13          db 'Very important text', 0
text20          db 'I lose more than 4 hours', 0
text21          db 'This register is used to lock the configuration of the port', 0
text22          db ' \(*-*)/ ', 0
text23          db 'The value of the first character defined in the font.', 0      ; length = 38 + 1
text30          db 'This document provides a description,', 0
text31          db 'specifications, and design related information on the MPU-9250 MotionTracking device.', 0
text32          db 'The average width of characters in the font', 0
text33          db 'HELP', 0
text40          db '1000 - 7', 0
text41          db 'The wingdi.h header defines TEXTMETRIC as an alias', 0
text42          db 'JOJO Bizarre Adventure', 0
text43          db 'Very important text', 0
text50          db 'I lose more than 4 hours', 0
text51          db 'This register is used to lock the configuration of the port', 0
text52          db ' \(*-*)/ ', 0
text53          db 'The value of the first character defined in the font.', 0      ; length = 38 + 1

allText         dd text00, text01, text02, text03,\
                   text10, text11, text12, text13,\
                   text20, text21, text22, text23,\
                   text30, text31, text32, text33,\
                   text40, text41, text42, text43,\
                   text50, text51, text52, text53

ROW_COUNT       dd      4
LINE_COUNT      dd      6
MAX_LENGTH      dd      85

msg             MSG
rect            RECT
textMetrics     TEXTMETRIC
;drawTextParams  DRAWTEXTPARAMS sizeof.DRAWTEXTPARAMS, 5, 5, 4, 0
hMainWnd        dd      ?
hInstance       dd      ?
hBackgroundBmp  dd      ?
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