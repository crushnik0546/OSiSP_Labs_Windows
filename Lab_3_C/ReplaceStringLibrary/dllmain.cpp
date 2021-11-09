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

    if (NULL == hProcess)
    {
        return -1;
    }

    SYSTEM_INFO system_info;
    GetSystemInfo(&system_info);

    char *start_adress = (char *)system_info.lpMinimumApplicationAddress;
    MEMORY_BASIC_INFORMATION memory_info;

    char info_buffer[] = "BaseAddress: %X, AllocationBase: %X, AllocationProtect: %X, RegionSize: %X, State: %X, Protect: %X, Type: %X ";
    char res_buffer[256];
    while (start_adress < system_info.lpMaximumApplicationAddress)
    {
        if (!VirtualQueryEx(hProcess, start_adress, &memory_info, sizeof(memory_info)))
        {
            return -1;
        }

        /*sprintf(res_buffer, info_buffer, memory_info.BaseAddress, memory_info.AllocationBase, memory_info.AllocationProtect,
            memory_info.RegionSize, memory_info.State, memory_info.Protect, memory_info.Type);
        MessageBoxA(HWND_DESKTOP, (LPCSTR)res_buffer, NULL, MB_OK);*/

        if ((MEM_COMMIT == memory_info.State) && (PAGE_WRITECOPY == memory_info.AllocationProtect))
        {
            char *start_page = (char *)memory_info.BaseAddress;
            char *page = (char *)malloc(memory_info.RegionSize * sizeof(char));

            if (NULL == page)
            {
                return -1;
            }

            // last param not NULL later
            if (!ReadProcessMemory(hProcess, start_page, page, memory_info.RegionSize, NULL))
            {
                return -1;
            }



            free(page);
        }

        start_adress += memory_info.RegionSize;
    }



    MessageBox(HWND_DESKTOP, L"Hello!", L"Hi", MB_OK);
    return 0;
}
