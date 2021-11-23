#include "thread_pool.h"
#define BUFFER_SIZE 100

void do_thread_work(int id);

task queue[BUFFER_SIZE];
int queue_offset = 0;
int queue_size = 0;
HANDLE *thread_list;
int threads_count;
CRITICAL_SECTION crit_section;
CONDITION_VARIABLE buffer_not_full, buffer_not_empty;

void create_thread_pool(int count)
{
	threads_count = count;
	InitializeCriticalSection(&crit_section);
	InitializeConditionVariable(&buffer_not_full);
	InitializeConditionVariable(&buffer_not_empty);

	thread_list = (HANDLE *)malloc(threads_count * sizeof(HANDLE));
	if (NULL != thread_list)
	{
		for (int i = 0; i < threads_count; i++)
		{
			thread_list[i] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)do_thread_work, (LPVOID)i, 0, 0);
		}
		printf("---Initialization---\n");
	}
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
	while (TRUE)
	{
		EnterCriticalSection(&crit_section);
		printf("---Thread id = %d entered in critical section---\n", id);

		while (0 == queue_size)
		{
			// если в очереди нет задач, то ждать пока они добавятся
			SleepConditionVariableCS(&buffer_not_empty, &crit_section, INFINITE);
		}

		ts = queue[queue_offset];
		printf("---Thread id = %d took task from queue---\n", id);
		ts();

		queue_size--;
		queue_offset++;

		if (BUFFER_SIZE == queue_offset)
		{
			queue_offset = 0;
		}

		LeaveCriticalSection(&crit_section);

		// если не было места в очереди для новой задачи, то сообщить что оно появилось
		WakeConditionVariable(&buffer_not_full);
	}
}

void add_task_for_threadpool(task ts)
{
	EnterCriticalSection(&crit_section);
	while (BUFFER_SIZE == queue_size)
	{
		// если буффер полный, то ожидание, пока будут обработаны tasks  в очереди
		SleepConditionVariableCS(&buffer_not_full, &crit_section, INFINITE);
	}

	queue[(queue_offset + queue_size) % BUFFER_SIZE] = ts;

	queue_size++;

	LeaveCriticalSection(&crit_section);

	// если поток ждет добавления элемента в очередь, то разбудить его
	WakeConditionVariable(&buffer_not_empty);
}