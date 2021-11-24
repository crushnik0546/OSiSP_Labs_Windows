#include "thread_pool.h"

#define BUFFER_SIZE 100

void do_thread_work(int id);

task_args queue[BUFFER_SIZE];
int queue_offset = 0;
int queue_size = 0;

HANDLE *thread_list;
int threads_count;

CRITICAL_SECTION crit_section;
CONDITION_VARIABLE buffer_not_full, buffer_not_empty;

volatile BOOL is_stop = FALSE;

void create_thread_pool(int count)
{
	InitializeCriticalSection(&crit_section);
	InitializeConditionVariable(&buffer_not_full);
	InitializeConditionVariable(&buffer_not_empty);

	threads_count = count;
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
	wait_all_tasks();

	for (int i = 0; i < threads_count; i++)
	{
		CloseHandle(thread_list[i]);
	}

	free(thread_list);

	DeleteCriticalSection(&crit_section);
}

void wait_all_tasks()
{
	InterlockedCompareExchange(&is_stop, TRUE, FALSE);

	WakeAllConditionVariable(&buffer_not_empty);
	WakeAllConditionVariable(&buffer_not_full);

	WaitForMultipleObjects(threads_count, thread_list, TRUE, INFINITE);
}

void add_task_for_threadpool(task_args task)
{
	EnterCriticalSection(&crit_section);
	while (BUFFER_SIZE == queue_size)
	{
		// если буффер полный, то ожидание, пока будут обработаны tasks  в очереди
		SleepConditionVariableCS(&buffer_not_full, &crit_section, INFINITE);
	}

	queue[(queue_offset + queue_size) % BUFFER_SIZE] = task;

	queue_size++;

	LeaveCriticalSection(&crit_section);

	// если поток ждет добавления элемента в очередь, то разбудить его
	WakeConditionVariable(&buffer_not_empty);
}

void do_thread_work(int id)
{
	task_args task;
	while (TRUE)
	{
		EnterCriticalSection(&crit_section);
		printf("---Thread id = %d entered in critical section---\n", id);

		while (0 == queue_size && FALSE == is_stop)
		{
			// если в очереди нет задач, то ждать пока они добавятся
			SleepConditionVariableCS(&buffer_not_empty, &crit_section, INFINITE);
		}

		// запрос на окончание обработки очереди
		if (TRUE == is_stop && 0 == queue_size)
		{
			LeaveCriticalSection(&crit_section);
			break;
		}

		task = queue[queue_offset];

		queue_size--;
		queue_offset++;

		if (BUFFER_SIZE == queue_offset)
		{
			queue_offset = 0;
		}

		LeaveCriticalSection(&crit_section);

		// если не было места в очереди для новой задачи, то сообщить что оно появилось
		WakeConditionVariable(&buffer_not_full);

		printf("---Thread id = %d took task from queue---\n", id);
		task.ts(task.arg);
	}
}
