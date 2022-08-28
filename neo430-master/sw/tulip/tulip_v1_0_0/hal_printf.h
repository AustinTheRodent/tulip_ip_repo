#include <neo430.h>

int putchar(int c);
void printchar(char **str, int c);
int prints(char **out, const char *string, int width, int pad);
int printi(char **out, int i, int b, int sg, int width, int pad, int letbase);
int print(char **out, int *varg);
int hal_printf(const char *format, ...);
int sprintf(char *out, const char *format, ...);
