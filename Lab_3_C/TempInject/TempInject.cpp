#include <stdio.h>
#include <Windows.h>

char *find_str;

int main()
{
    //const char find[] = "12345";

    find_str = (char *)malloc(sizeof(char) * strlen("abc\n"));

    strcpy(find_str, "abc\n");

    while (1)
    {
        printf("Current value of string: %s\n", find_str);
        getchar();
    }

    return 0;
}
