#include <stdio.h>
#include <queue>

typedef void (*task)(void);

void Hello()
{
    printf("Hello\n");
}

int main()
{
    task ts1;
    ts1 = Hello;
    ts1();

    std::queue<task> queue1;
    queue1.push(ts1);
    queue1.push(ts1);
    queue1.push(ts1);

    for (int i = 0; i <= 2; i++)
    {
        task tmp = queue1.front();
        tmp();
        queue1.pop();
    }
}

