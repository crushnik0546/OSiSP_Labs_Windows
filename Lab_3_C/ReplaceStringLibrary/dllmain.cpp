// dllmain.cpp : Определяет точку входа для приложения DLL.
#define STRING_REPLACE_EXPORTS
#include "replace_string.h"
#include <Windows.h>
#include <stdio.h>

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

//------------------------------------------------------------

int replace_string(char *find_str, char *replace_str)
{
    MessageBox(HWND_DESKTOP, L"Hello!", L"Hi", MB_OK);
    return 20;
}
