﻿#include <stdlib.h>
#include <stdio.h>
#include <Windows.h>
#include "replace_string.h"

int main()
{
    char *find_str;
    char *replace_str;

    LPCSTR str1 = "Hello";

    find_str = (char *)malloc(5 * sizeof(char));
    replace_str = (char *)malloc(5 * sizeof(char));

    int k = replace_string(GetCurrentProcessId(), find_str, replace_str);

    printf("%d", k);

    free(find_str);
    free(replace_str);

    return 0;
}