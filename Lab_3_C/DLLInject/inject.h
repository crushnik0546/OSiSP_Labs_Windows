#pragma once

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