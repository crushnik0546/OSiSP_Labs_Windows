#include <Windows.h>
#include <tlhelp32.h>
#include <stdio.h>

const char *path_to_library = "..\\..\\ReplaceStringLibrary\\Debug\\ReplaceStringLibrary.dll";

DWORD get_process_id_by_name(LPCTSTR process_name);
int inject(DWORD pid, char *find_str, char *replace_str);
DWORD get_proc_offset(const char *library_name, const char *procedure_name);


typedef struct {
    DWORD pid;
    char *find_string;
    char *replace_string;
} param_info;

int main() {
    DWORD pid = get_process_id_by_name(L"TempInject.exe");

    char find[] = "abc";
    char replace[] = "zxc";

    inject(pid, find, replace);
    
    //Inject(pid, sourceString, replacementString);
}

int inject(DWORD pid, char *find_str, char *replace_str)
{
    HANDLE process = OpenProcess(PROCESS_CREATE_THREAD | PROCESS_VM_OPERATION | PROCESS_VM_WRITE, FALSE, pid);
    if (NULL == process)
    {
        return -1;
    }

    LPVOID loadlib_addr = GetProcAddress(GetModuleHandle(L"kernel32.dll"), "LoadLibraryA");
    if (NULL == loadlib_addr)
    {
        return -1;
    }

    LPVOID params_addr = VirtualAllocEx(process, NULL, strlen(path_to_library) * sizeof(char), MEM_COMMIT, PAGE_EXECUTE_READWRITE);

    if (NULL == params_addr)
    {
        return -1;
    }

    //SIZE_T bytes_written;
    BOOL is_written = WriteProcessMemory(process, params_addr, path_to_library, strlen(path_to_library) * sizeof(char), NULL);
    if (!is_written)
    {
        return -1;
    }

    HANDLE remote_thread = CreateRemoteThread(process, NULL, 0, (LPTHREAD_START_ROUTINE)loadlib_addr, params_addr, 0, NULL);
    if (NULL == remote_thread)
    {
        return -1;
    }

    printf("The remote thread was successfully created.\n");

    DWORD ret_event = WaitForSingleObject(remote_thread, INFINITE);
    /*if (WAIT_FAILED == ret_event)
    {
        return -1;
    }*/

    DWORD load_library_return_from_remote_thread = 0;
    GetExitCodeThread(remote_thread, &load_library_return_from_remote_thread);

    CloseHandle(remote_thread);

    if (0 == load_library_return_from_remote_thread)
    {
        return -1;
    }

    //---------------------------------------

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
    if (NULL == params_addr)
    {
        return -1;
    }

    is_written = WriteProcessMemory(process, params_addr, &params, sizeof(param_info), NULL);
    if (!is_written)
    {
        return -1;
    }

    DWORD proc_addr = load_library_return_from_remote_thread + proc_offset;
    
    remote_thread = CreateRemoteThread(process, NULL, 0, (LPTHREAD_START_ROUTINE)proc_addr, params_addr, 0, NULL);
    if (NULL == remote_thread)
    {
        return -1;
    }

    WaitForSingleObject(remote_thread, INFINITE);

    printf("String replaced\n");

    CloseHandle(remote_thread);
    CloseHandle(process);
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