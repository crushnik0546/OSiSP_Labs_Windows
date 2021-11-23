#include "thread_pool.h"

typedef void (*task)(void);

void Hello()
{
    printf("Hello\n");
}

int main()
{
    task ts;
    ts = Hello;
    create_thread_pool(3);

    add_task_for_threadpool(ts);
    add_task_for_threadpool(ts);
    add_task_for_threadpool(ts);

    Sleep(5000);
}

