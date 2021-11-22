#pragma once
#include <queue>
#include <Windows.h>

// delegate
typedef void (*task)(void);

std::queue<task> task_queue;
HANDLE *thread_list;
int threads_count;
CRITICAL_SECTION crit_section;