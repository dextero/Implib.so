#include <stdio.h>

extern int foo(int x);
extern int bar(int x);

int main(void) {
  printf("%d %d\n", foo(5), bar(5));
  return 0;
}
