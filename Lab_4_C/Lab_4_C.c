#include "thread_pool.h"


void sort_lines(char **lines, int lines_count);

int main()
{
    int threads_count;

    printf("Enter threads count: ");
    scanf("%d", &threads_count);

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

    const char* delims = "\r\n";
    char **lines = NULL;

    char *next_token = strtok(buffer, delims);
    int lines_count = 0, lines_offset = -1;

    while (next_token)
    {
        lines_count++;
        lines_offset++;
        lines = (char **)realloc(lines, lines_count * sizeof(char *));
        lines[lines_offset] = (char *)malloc((strlen(next_token) + 1) * sizeof(char));
        memcpy(lines[lines_offset], next_token, strlen(next_token) + 1);

        next_token = strtok(NULL, delims);
    }

    lines_count--;
    free(lines[lines_count]);

    printf("Strings before sort:\n");
    for (int i = 0; i < lines_count; i++)
    {
        printf("Line %d: %s\n", i, lines[i]);
    }

    int lines_per_thread = lines_count / threads_count;

    create_thread_pool(threads_count);

    lines_offset = 0; 
    task_args task;
    task.ts = sort_lines;
    task.lines_count = lines_per_thread;
    for (int i = 0; i < threads_count; i++, lines_offset += lines_per_thread)
    {
        task.lines = &lines[lines_offset];
        if (threads_count - 1 == i)
        {
            task.lines_count = lines_count - lines_offset;
        }

        add_task_for_threadpool(task);
    }

    wait_all_tasks();

    //sort_lines(lines, lines_count);

    printf("\nStrings after sort:\n");
    for (int i = 0; i < lines_count; i++)
    {
        printf("Line %d: %s\n", i, lines[i]);
    }

}

void sort_lines(char **lines, int lines_count)
{
    for (int i = 0; i < lines_count - 1; i++)
    {
        for (int j = i; j < lines_count; j++)
        {
            if (strcmp(lines[i], lines[j]) > 0)
            {
                int str1_len = strlen(lines[i]) + 1;
                int str2_len = strlen(lines[j]) + 1;
                char *tmp = (char *)malloc(str1_len * sizeof(char));

                memcpy(tmp, lines[i], str1_len);

                realloc(lines[i], str2_len);
                memcpy(lines[i], lines[j], str2_len);

                realloc(lines[j], str1_len);
                memcpy(lines[j], tmp, str1_len);

                free(tmp);
            }
        }
    }
}
