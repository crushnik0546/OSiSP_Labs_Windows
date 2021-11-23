#include "thread_pool.h"

void do_thread_work(int id);

std::queue<task> task_queue;
HANDLE *thread_list;
int threads_count;
CRITICAL_SECTION crit_section;
CONDITION_VARIABLE conditional_var;

void create_thread_pool(int count)
{
	threads_count = count;
	InitializeCriticalSection(&crit_section);
	InitializeConditionVariable(&conditional_var);

	thread_list = (HANDLE *)malloc(threads_count * sizeof(HANDLE));

	for (int i = 0; i < threads_count; i++)
	{
		thread_list[i] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)do_thread_work, (LPVOID)i, 0, 0);
	}
	printf("---Initialization was done---\n");
}

void delete_tread_pool()
{
	for (int i = 0; i < threads_count; i++)
	{
		CloseHandle(thread_list[i]);
	}

	free(thread_list);

	DeleteCriticalSection(&crit_section);
}

void do_thread_work(int id)
{
	task ts;
	while (1)
	{
		EnterCriticalSection(&crit_section);
		printf("---Thread id = %d entered in critical section---\n", id);

		while (task_queue.empty())
		{
			SleepConditionVariableCS(&conditional_var, &crit_section, INFINITE);
		}

		printf("---Thread id = %d got task from queue---\n", id);
		ts = task_queue.front();
		task_queue.pop();
		ts();

		LeaveCriticalSection(&crit_section);
	}
}

void add_task_for_threadpool(task ts)
{
	EnterCriticalSection(&crit_section);
	task_queue.push(ts);
	WakeConditionVariable(&conditional_var);
	LeaveCriticalSection(&crit_section);
}