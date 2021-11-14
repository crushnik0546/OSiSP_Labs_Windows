#include "replace_string.h"

int main()
{
    char find[100];
    char replace[100];

    printf("What string I should find : ");
    fgets(find, sizeof(find), stdin);
    printf("How I should change this string (the same length): ");
    fgets(replace, sizeof(replace), stdin);

    int str_len = strlen(find);

    char *find_str = (char *)malloc(sizeof(char) * str_len);

    if (NULL == find_str)
    {
        printf("Insufficient memory available\n");
        return -1;
    }

    memcpy(find_str, find, str_len);
    find_str[str_len] = 0;

    printf("String before dll call: %s\n", find_str);

    param_info params;
    params.pid = GetCurrentProcessId();
    params.find_string = find_str;
    params.replace_string = replace;

    if (!replace_string(&params))
    {
        printf("String was changed successfully!\n");
        printf("String after dll call: %s\n", find_str);
    }
    else
    {
        printf("String was not changed. DLL error");
    }

    return 0;
}