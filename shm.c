#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

struct {
    struct spinlock lock;
    struct shm_page {
        uint id; // an int given by the program to specify the shared memory segment; two programs the shm_open the same id shoudl get the same physical page
        char *frame; // a pointer to the physical frame; a pointer to the shared physical page
        int refcnt; // the number of processes sharing the page; if the shared memory region is closed, DO NOT REMOVE the page unless NO OTHER process is sharing it
    } shm_pages[64];
} shm_table;

void shminit() {
    int i;
    initlock(&(shm_table.lock), "SHM lock");
    acquire(&(shm_table.lock));
    for (i = 0; i< 64; i++) { //64 pages in the shm_table
        shm_table.shm_pages[i].id =0;
        shm_table.shm_pages[i].frame =0;
        shm_table.shm_pages[i].refcnt =0;
    }
    release(&(shm_table.lock));
}

int shm_open(int id, char **pointer) {
    return 0; 
}


int shm_close(int id) {
    return 0;
}
