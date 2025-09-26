#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int pid = getpid();

  printf("Current PID: %d\n", pid);

  // test default nice
  int nice = get_priority(pid);
  printf("Default nice value: %d\n", nice);

  // set new nice value
  if (set_priority(pid, 10) == 0) {
    printf("Set nice to 10\n");
  } else {
    printf("Failed to set nice\n");
  }

  // get new nice value
  nice = get_priority(pid);
  printf("Updated nice value: %d\n", nice);

  // test clamping
  set_priority(pid, 100);
  nice = get_priority(pid);
  printf("Clamped nice value (should be 39): %d\n", nice);

  exit(0);
}