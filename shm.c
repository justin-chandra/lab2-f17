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
    //CS153 added
    //NOTE: Use the embedded spin lock to avoid race conditions.
    // MORE SPECIFICALLY: Use the same acquire and release calls that are in shm_init
    int i;
    acquire(&(shm_table.lock));
    for (i = 0; i < 64; ++i) {
        if (id == shm_table.shm_pages[i].id) {
            cprintf("%d", shm_table.shm_pages[i]);
            break;
        }
    }
    release(&(shm_table.lock));
    //CASE ONE: ANOTHER PROCESS CALLED SHM_OPEN BEFORE "US"
    // 1. Find the physical address of the page in the table.
    // uint phys_addr = V2P(shm_table.shm_pages[i].id);
    // 2. Map it into an available page in the virtual address space (aka, add it to the page table). (HINT: use mappages)
    uint va = PGROUNDUP(myproc()->sz);
    //TODO: No process in this file's code that can be consulted?
    // 3. Increment refcnt and return the pointer to the virtual address with something like:
    //TODO: VERIFY
    *pointer = (char * ) va;
    // 4. Update sz becuase the size of the virtual address space expanded.
    //TODO: sz = shm_table...

    //CASE TWO: THE SHARED MEMORY SEGMENT DNE (NOT FOUND IN TABLE), AKA, "WE" ARE THE FIRST SHM_OPEN
    // 1. Find an empty entry in the shm_table.
    // 2. Initialize its id to the id passed in as a parameter.
    acquire(&(shm_table.lock));
    for (i = 0; i < 64; ++i) {
        if (shm_table.shm_pages[i].id == 0) {
            shm_table.shm_pages[i].id = id;
        }
    }
    release(&(shm_table.lock));
    // 3. kmalloc a page.

    // 4. Store its address in frame. "We got our physical page."

    // 5. Set refcnt = 1.

    // 6. Map the page to an available virtual address space page ("e.g. sz").

    // 7. Return a pointer through char ** pointer.

    //CASE TWO: THE SHARED MEMORY SEGMENT DNE (NOT FOUND IN TABLE), AKA, "WE" ARE THE FIRST SHM_OPEN
    // 1. Find an empty entry in the shm_table.

    // 2. Initialize its id to the id passed in as a parameter.

    // 3. kmalloc a page.

    // 4. Store its address in frame. "We got our physical page."

    // 5. Set refcnt = 1.

    // 6. Map the page to an available virtual address space page ("e.g. sz").

    // 7. Return a pointer through char ** pointer.


    return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
    //you write this too!




    return 0; //added to remove compiler warning -- you should decide what to return
}
