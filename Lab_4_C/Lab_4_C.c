#include "thread_pool.h"

typedef void (*task)(void);

void Hello1()
{
    printf("Hello_1\n");
    Sleep(1000);
}

void Hello2()
{
    printf("Hello_2\n");
    Sleep(2000);
}

void Hello3()
{
    printf("Hello_3\n");
    Sleep(3000);
}

void Hello4()
{
    printf("Hello_4\n");
    Sleep(4000);
}

int main()
{
    HANDLE file;
    char *file_name = "text.txt";

    file = CreateFileA(file_name, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

    if (file == INVALID_HANDLE_VALUE)
    {
        printf("Create File error\n");
        return -1;
    }

    DWORD file_size = GetFileSize(file, NULL);
    if (INVALID_FILE_SIZE == file_size)
    {
        CloseHandle(file);
        printf("Get file size error\n");
        return -1;
    }

    char *buffer = (char *)malloc((file_size + 1) * sizeof(char));

    if (FALSE == ReadFile(file, buffer, file_size, NULL, NULL))
    {
        CloseHandle(file);
        free(buffer);
        printf("Read file failed\n");
        return -1;
    }

    CloseHandle(file);


}

void sort_lines(char *lines[])
{

}
