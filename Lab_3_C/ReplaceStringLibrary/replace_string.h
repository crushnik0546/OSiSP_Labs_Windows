#pragma once

#ifdef STRING_REPLACE_EXPORTS
#define STRING_REPLACE_API __declspec(dllexport)
#else
#define STRING_REPLACE_API __declspec(dllimport)
#endif // STRING_REPLACE_EXPORTS

extern "C" STRING_REPLACE_API int replace_string(int pid, char *find_str, char *replace_str);
