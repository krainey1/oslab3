/**
 * @file ps.c
 * @author Ben Mannal
 * @brief user level program ps
 * @version 0.1
 * @date 2025-09-26
 * 
 * @copyright Copyright (c) 2025
 * 
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/**
 * @brief 
 * 
 * @param argc 
 * @param argv 
 * @return int 
 */
int
main(int argc, char *argv[])
{
  cps();   // kernel prints process info
  exit(0);
}
