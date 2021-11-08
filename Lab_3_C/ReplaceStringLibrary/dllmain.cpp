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

int replace_string(int pid, char *find_str, char *replace_str)
{
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_VM_WRITE, false, pid);

    MessageBox(HWND_DESKTOP, L"Hello!", L"Hi", MB_OK);
    return 20;
}
