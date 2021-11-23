#pragma once
#include <queue>
#include <Windows.h>

// delegate
typedef void (*task)(void);

void create_thread_pool(int count);
void delete_tread_pool();
void add_task_for_threadpool(task ts);