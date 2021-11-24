#pragma once
#include <stdio.h>
#include <Windows.h>

// delegate
typedef void (*task)(char **);
typedef struct {
	task ts;
	char **arg;
}task_args;

void create_thread_pool(int count);
void delete_tread_pool();
void add_task_for_threadpool(task_args ts);
void wait_all_tasks();