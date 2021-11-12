#include <stdlib.h>
#include <stdio.h>
#include <Windows.h>
#include "replace_string.h"

int main()
{
    char find[] = "12345";
    char replace[] = "67890";

    int str_len = strlen(find);

    char *find_str = (char *)malloc(sizeof(char) * str_len);

    if (NULL == find_str)
        return -1;

    memcpy(find_str, find, str_len);
    find_str[str_len] = 0;

    //printf("Adrees find_string: %X\n", find_str);

    /*char *replace_str = (char *)malloc(sizeof(char) * str_len);
    memcpy(replace_str, replace, str_len);
    replace_str[str_len] = 0;*/

    printf("String before dll call: %s\n", find);

    LPCSTR str1 = "Hello";

    int k = replace_string(GetCurrentProcessId(), find_str, replace);

    printf("String after dll call: %s\n", find_str);

    //free(find_str);
    //free(replace_str);

    return 0;
}