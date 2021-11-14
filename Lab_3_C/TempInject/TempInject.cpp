#include <stdio.h>
#include <Windows.h>

char *find_str;

int main()
{
    //const char find[] = "12345";

    find_str = (char *)malloc(sizeof(char) * 6);

    strcpy(find_str, "12345");

    while (1)
    {
        printf("Current value of string: %s\n", find_str);
//        for (int i = 0; i <= 100000000; i++) {}
    }

    return 0;
}

