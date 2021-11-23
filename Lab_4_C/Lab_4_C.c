#include "thread_pool.h"

typedef void (*task)(void);

void Hello1()
{
    printf("Hello_1\n");
}

void Hello2()
{
    printf("Hello_2\n");
}

void Hello3()
{
    printf("Hello_3\n");
}

void Hello4()
{
    printf("Hello_4\n");
}

int main()
{
    task ts1, ts2, ts3, ts4;
    ts1 = Hello1;
    ts2 = Hello2;
    ts3 = Hello3;
    ts4 = Hello4;

    create_thread_pool(15);

    for (int i = 0; i <= 30; i++)
    {
        add_task_for_threadpool(ts1);
        add_task_for_threadpool(ts2);
        add_task_for_threadpool(ts3);
        add_task_for_threadpool(ts4);
    }

    Sleep(5000);
}

