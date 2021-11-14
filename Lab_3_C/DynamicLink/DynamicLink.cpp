#include "replace_string.h"

typedef int __cdecl DLLPROC(param_info* params);

int main()
{
    char find[] = "abcd";
    char replace[] = "zxcv";

    int str_len = strlen(find);

    char *find_str = (char *)malloc(sizeof(char) * str_len);

    if (NULL == find_str)
        return -1;

    memcpy(find_str, find, str_len);
    find_str[str_len] = 0;

    HINSTANCE lib;
    DLLPROC *string_replace;
    BOOL fFreeResult;

    lib = LoadLibrary(TEXT("ReplaceStringLibrary.dll"));

    if (NULL == lib)
    {
        return -1;
    }

    string_replace = (DLLPROC *)GetProcAddress(lib, "replace_string");

    if (NULL == string_replace)
    {
        return -1;
    }

    printf("String before dll call: %s\n", find);

    param_info params;
    params.pid = GetCurrentProcessId();
    params.find_string = find_str;
    params.replace_string = replace;

    int k = string_replace(&params);

    printf("String after dll call: %s\n", find_str);

    fFreeResult = FreeLibrary(lib);

    return 0;
}
