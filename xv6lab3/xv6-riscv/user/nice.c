/**
 * @file nice.c
 * @author Katelynn Rainey
 * @brief change nice value of process of input pid to input priority
 * @version 0.1
 * @date 2025-09-26
 * 
 */
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char * argv[])
{
    if(argc < 3)
    {
        printf("Not Enough Arguments\n");
        exit(1);
    }
    int pid = atoi(argv[1]);
    int priority = atoi(argv[2]);
    int p = set_priority(pid, priority); 
    if(p != 0)
    {
        printf("ERROR: Priority Not Set\n");
        exit(1);
    }
    exit(0);

}