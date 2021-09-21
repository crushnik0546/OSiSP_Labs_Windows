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

        invoke  GetModuleHandle, ebx
        mov     [hInst], eax

        invoke  RegisterClassEx, wcex
        invoke  CreateWindowEx, ebx, className, windowName, WS_VISIBLE or WS_POPUP or WS_MAXIMIZE,\
                ebx, ebx , ebx , ebx, ebx, ebx, [hInst], ebx

        mov     [hMainWnd], eax
        invoke  GetClientRect, [hMainWnd], rect

        invoke  GetDC, ebx
        mov     [hdc], eax
        invoke  CreateCompatibleDC, [hdc]
        mov     [hBackDC], eax
        invoke  CreateCompatibleBitmap, [hdc], [rect.right], [rect.bottom]
        mov     [hBackBMP], eax
        invoke  SelectObject, [hBackDC], [hBackBMP]
        invoke  ReleaseDC, ebx, [hdc]

        stdcall LoadBitmapDC, backName
        mov     [hBackgroundDC], eax
        stdcall LoadBitmapDC, playerName
        mov     [hPlayerDC], eax
        stdcall LoadBitmapDC, slimeName
        mov     [hSlimeDC], eax
        stdcall LoadBitmapDC, AngryPlayerName
        mov     [hPlayerAngrDC], eax

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

proc LoadBitmapDC, fileName

        locals
                resultDC        dd      ?
                hdc             dd      ?
                hBitmap         dd      ?
        endl

        invoke LoadImage,ebx,[fileName],IMAGE_BITMAP,ebx,ebx,LR_LOADFROMFILE
        mov    [hBitmap], eax

        invoke  GetDC, ebx
        mov     [hdc], eax
        invoke  CreateCompatibleDC, eax
        mov     [resultDC], eax
        invoke  SelectObject, [resultDC], [hBitmap]

        invoke  ReleaseDC, ebx, [hdc]

        mov     eax, [resultDC]

        ret
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
        cmp     eax, WM_DESTROY
        je      .WMDestroy
        cmp     eax, WM_KEYDOWN
        je      .WMKeyDown
        cmp     eax, WM_MOUSEWHEEL
        je      .WMMouseWheel

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .ExitWindowProc


.WMPaint:
        stdcall Draw

        lea     esi, [ps]
        invoke  BeginPaint, [hWnd], esi
        mov     [hdc], eax

        invoke  BitBlt, [hdc], 0, 0, [rect.right], [rect.bottom], [hBackDC], 0, 0, SRCCOPY
        invoke  EndPaint, [hWnd], esi

        jmp     .returnZero

.WMKeyDown:
        cmp     [wParam], VK_ESCAPE
        je      .WMDestroy

        stdcall MoveByKey, [wParam]
        invoke  InvalidateRect, [hWnd], 0, 0
        jmp     .returnZero

.WMMouseWheel:

        stdcall MoveByWheel, [wParam]
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

        invoke  StretchBlt, [hBackDC], 0, 0, [rect.right], [rect.bottom], [hBackgroundDC], 0, 0, 1920, 1080, SRCCOPY
        invoke  GdiTransparentBlt, [hBackDC], [slimePositionX], [slimePositionY], 100, 100, [hSlimeDC], 0, 0, 807, 722, 0x00000000

        cmp     [paimonFlag], 0
        jne     .AngryPaimon
.GoodPaimon:
        invoke  GdiTransparentBlt, [hBackDC], [paimonPositionX], [paimonPositionY], [playerWidth], [playerHeight], [hPlayerDC], 0, 0, 551, 835, 0x00000000
        jmp     .ReturnDraw
.AngryPaimon:
        invoke  GdiTransparentBlt, [hBackDC], [paimonPositionX], [paimonPositionY], [playerWidth], [playerHeight], [hPlayerAngrDC], 0, 0, 652, 852, 0x00000000
.ReturnDraw:
        ret
endp

proc MoveByKey keyCode

        mov     eax, [keyCode]

.Key_W:
        cmp     eax, 'W'
        jne     .Key_S
        sub     [paimonPositionY], 5
        jmp     .ReturnMoveByKey
.Key_S:
        cmp     eax, 'S'
        jne     .Key_A
        add     [paimonPositionY], 5
        jmp     .ReturnMoveByKey
.Key_A:
        cmp     eax, 'A'
        jne     .Key_D
        sub     [paimonPositionX], 5
        jmp     .ReturnMoveByKey
.Key_D:
        cmp     eax, 'D'
        jne     .ReturnMoveByKey
        add     [paimonPositionX], 5

.ReturnMoveByKey:
        stdcall CheckBorders
        stdcall ChangePlayer
        xor     eax, eax
        ret
endp

proc MoveByWheel wheelInfo

        mov     eax, [wheelInfo]
        and     eax, 0x0000FFFF

        cmp     eax, MK_SHIFT
        jne     .CheckY
.CheckX:
        mov     eax, [wheelInfo]
        and     eax, 0xFFFF0000

        cmp     eax, 0
        jl      .ToRight
.ToLeft:
        sub     [paimonPositionX], 5
        jmp     .ReturnMoveByWheel

.ToRight:
        add     [paimonPositionX], 5
        jmp     .ReturnMoveByWheel

.CheckY:
        mov     eax, [wheelInfo]
        and     eax, 0xFFFF0000

        cmp     eax, 0
        jl      .ToBottom
.ToTop:
        sub     [paimonPositionY], 5
        jmp     .ReturnMoveByWheel

.ToBottom:
        add     [paimonPositionY], 5

.ReturnMoveByWheel:
        stdcall CheckBorders
        xor     eax, eax

        ret
endp

proc CheckBorders

.CheckLeft:
        mov     eax, [paimonPositionX]
        cmp     eax, [leftBorder]
        jne      .CheckRight
        mov     [paimonPositionX], leftPosition

.CheckRight:
        add     eax, [playerWidth]
        cmp     eax, [rightBorder]
        jne      .CheckTop
        mov     [paimonPositionX], rightPosition

.CheckTop:
        mov     eax, [paimonPositionY]
        cmp     eax, [topBorder]
        jne      .CheckBottom
        mov     [paimonPositionY], topPosition

.CheckBottom:
        add     eax, [playerHeight]
        cmp     eax, [bottomBorder]
        jne     .ReturnCheckBorders
        mov     [paimonPositionY], bottomPosition

.ReturnCheckBorders:
        xor     eax, eax
        ret
endp

proc ChangePlayer

        ; approximate values of position
        ; need fix some day...
        cmp     [paimonPositionX], 170
        jb      .Good
        cmp     [paimonPositionY], 160
        jb      .Good

.CmpNext:
        cmp     [paimonPositionX], 300
        ja      .Good
        cmp     [paimonPositionY], 280
        ja      .Good

.Anger:
        mov     [paimonFlag], 1
        jmp     .ReturnChangePlayer
.Good:
        mov     [paimonFlag], 0
.ReturnChangePlayer:
        xor     eax, eax
        ret
endp

section '.data' data readable writeable

WINDOW_STYLE    = WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_OVERLAPPED

wcex            WNDCLASSEX sizeof.WNDCLASSEX, CS_GLOBALCLASS, WindowProc, 0, 0,\
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
hPlayerDC       dd      ?
hPlayerAngrDC   dd      ?
hSlimeDC        dd      ?
paimonFlag      db      0

leftBorder      dd      0
topBorder       dd      0
rightBorder     dd      1920
bottomBorder    dd      1080

paimonPositionX dd      100
paimonPositionY dd      100
playerWidth     dd      200
playerHeight    dd      300

leftPosition    =       10
topPosition     =       10    ;Width
rightPosition   =       1920 - 250 - 10
bottomPosition  =       1080 - 300 - 10
                              ;Height

slimePositionX  dd      300
slimePositionY  dd      300

backName        db      "back.bmp", 0
playerName      db      "player.bmp", 0
slimeName       db      "slime.bmp", 0
AngryPlayerName db      "angry.bmp", 0

section '.idata' import data readable writeable

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL"

        include "api\kernel32.inc"
        include "api\user32.inc"
        include "api\gdi32.inc"