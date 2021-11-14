#include "replace_string.h"

typedef int __cdecl DLLPROC(param_info* params);

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

    HINSTANCE lib;
    DLLPROC *string_replace;
    BOOL fFreeResult;

    lib = LoadLibrary(TEXT("ReplaceStringLibrary.dll"));

    if (NULL == lib)
    {
        printf("Fail Load library\n");
        return -1;
    }

    string_replace = (DLLPROC *)GetProcAddress(lib, "replace_string");

    if (NULL == string_replace)
    {
        printf("Fail Get process adress in user library\n");
        return -1;
    }

    param_info params;
    params.pid = GetCurrentProcessId();
    params.find_string = find_str;
    params.replace_string = replace;

    int k = string_replace(&params);

    printf("String after dll call: %s\n", find_str);

    fFreeResult = FreeLibrary(lib);

    return 0;
}
