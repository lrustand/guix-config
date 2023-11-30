#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
  setuid(0);
  setreuid(0, 0);
  char* args[] = {"systemctl", "unmask", "sleep.target"};
  execv("/usr/bin/systemctl", args);

  return 0;
}
