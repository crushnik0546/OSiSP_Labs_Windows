#include "inject.h"

int main() {
    DWORD pid = get_process_id_by_name(L"TempInject.exe");

    char find[100];
    char replace[100];

    printf("What string I should find : ");
    fgets(find, sizeof(find), stdin);
    printf("How I should change this string (the same length): ");
    fgets(replace, sizeof(replace), stdin);

    if (inject(pid, find, replace))
    {
        printf("Fail inject dll\n");
    }
   
}

int inject(DWORD pid, char *find_str, char *replace_str)
{
    HANDLE process = OpenProcess(PROCESS_CREATE_THREAD | PROCESS_VM_OPERATION | PROCESS_VM_WRITE, FALSE, pid);
    if (NULL == process)
    {
        printf("Fail Open process\n");
        return -1;
    }

    LPVOID loadlib_addr = GetProcAddress(GetModuleHandle(L"kernel32.dll"), "LoadLibraryA");
    LPVOID params_addr = VirtualAllocEx(process, NULL, strlen(path_to_library) * sizeof(char), MEM_COMMIT, PAGE_EXECUTE_READWRITE);

    BOOL is_written = WriteProcessMemory(process, params_addr, path_to_library, strlen(path_to_library) * sizeof(char), NULL);

    HANDLE remote_thread = CreateRemoteThread(process, NULL, 0, (LPTHREAD_START_ROUTINE)loadlib_addr, params_addr, 0, NULL);

    printf("The remote thread was successfully created.\n");

    DWORD ret_event = WaitForSingleObject(remote_thread, INFINITE);

    DWORD load_library_return_from_remote_thread = 0;
    GetExitCodeThread(remote_thread, &load_library_return_from_remote_thread);

    CloseHandle(remote_thread);

    if (0 == load_library_return_from_remote_thread)
    {
        printf("Fail get  address from LoadLibraryA return\n");
        return -1;
    }

//-----------------------------------------------------------------------------------------------------------------------------------

    DWORD proc_offset = get_proc_offset(path_to_library, "replace_string");

    LPVOID find_str_addr = VirtualAllocEx(process, NULL, strlen(find_str) * sizeof(char), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    is_written = WriteProcessMemory(process, find_str_addr, find_str, strlen(find_str) * sizeof(char), NULL);

    LPVOID replace_str_addr = VirtualAllocEx(process, NULL, strlen(replace_str) * sizeof(char), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    is_written = WriteProcessMemory(process, replace_str_addr, replace_str, strlen(replace_str) * sizeof(char), NULL);

    param_info params;
    params.pid = pid;
    params.find_string = (char *)find_str_addr;
    params.replace_string = (char *)replace_str_addr;

    params_addr = VirtualAllocEx(process, NULL, sizeof(param_info), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    is_written = WriteProcessMemory(process, params_addr, &params, sizeof(param_info), NULL);

    DWORD proc_addr = load_library_return_from_remote_thread + proc_offset;
    
    remote_thread = CreateRemoteThread(process, NULL, 0, (LPTHREAD_START_ROUTINE)proc_addr, params_addr, 0, NULL);

    WaitForSingleObject(remote_thread, INFINITE);

    printf("String replaced\n");

    CloseHandle(remote_thread);
    CloseHandle(process);

    return 0;
}

DWORD get_proc_offset(const char *library_name, const char *procedure_name) {
    DWORD offset = 0;
    HMODULE dll = LoadLibraryA(library_name);

    if (NULL != dll) {
        LPVOID procedure_addr = GetProcAddress(dll, procedure_name);
        if (NULL != procedure_addr) {
            offset = (DWORD)procedure_addr - (DWORD)dll;
        }
    }

    FreeLibrary(dll);
    return offset;
}

DWORD get_process_id_by_name(LPCTSTR process_name) {
    PROCESSENTRY32 pt;
    HANDLE hsnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    pt.dwSize = sizeof(PROCESSENTRY32);

    if (Process32First(hsnap, &pt)) {
        do {
            if (!lstrcmpi(pt.szExeFile, process_name)) {
                CloseHandle(hsnap);

                printf("Process TempInject.exe has pid %d", pt.th32ProcessID);

                return pt.th32ProcessID;
            }
        } while (Process32Next(hsnap, &pt));
    }

    CloseHandle(hsnap);
    return 0;
}