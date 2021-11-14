#pragma once

#include <Windows.h>
#include <stdio.h>

#ifdef STRING_REPLACE_EXPORTS
#define STRING_REPLACE_API __declspec(dllexport)
#else
#define STRING_REPLACE_API __declspec(dllimport)
#endif // STRING_REPLACE_EXPORTS

typedef struct {
    DWORD pid;
    char* find_string;
    char* replace_string;
} param_info;

extern "C" STRING_REPLACE_API int replace_string(param_info *params);
