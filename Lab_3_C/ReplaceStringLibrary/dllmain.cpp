#define STRING_REPLACE_EXPORTS
#include "replace_string.h"

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

int replace_string(param_info *params)
{
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_VM_WRITE, false, params->pid);

    if (NULL == hProcess)
    {
        return -1;
    }

    SYSTEM_INFO system_info;
    GetSystemInfo(&system_info);

    char *start_adress = (char *)system_info.lpMinimumApplicationAddress;
    MEMORY_BASIC_INFORMATION memory_info;

    /*char info_buffer[] = "BaseAddress: %X, AllocationBase: %X, AllocationProtect: %X, RegionSize: %X, State: %X, Protect: %X, Type: %X ";
    char res_buffer[256];*/
    while (start_adress < system_info.lpMaximumApplicationAddress)
    {
        if (!VirtualQueryEx(hProcess, start_adress, &memory_info, sizeof(memory_info)))
        {
            return -1;
        }

        if ((MEM_COMMIT == memory_info.State) && (PAGE_READWRITE == memory_info.Protect))
        {
            char *start_page = (char *)memory_info.BaseAddress;
            char *page = (char *)malloc(memory_info.RegionSize * sizeof(char));

            if (NULL == page)
            {
                return -1;
            }

            SIZE_T bytesRead = 0;
            if (!ReadProcessMemory(hProcess, start_page, page, memory_info.RegionSize, &bytesRead))
            {
                return -1;
            }

            int find_str_len = strlen(params->find_string);
            for (int i = 0; i < bytesRead - find_str_len; i++)
            {
                if (0 == memcmp(params->find_string, &page[i], find_str_len))
                {
                    char *real_addr = start_page + i;
                    for (int j = 0; j < find_str_len; j++)
                    {
                        real_addr[j] = params->replace_string[j];
                    }
                    real_addr[find_str_len] = 0;
                }
            }

            free(page);
        }

        start_adress += memory_info.RegionSize;
    }
    return 0;
}
