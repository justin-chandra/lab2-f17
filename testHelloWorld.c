#include "types.h"
#include "user.h"

void rec() {
    int a, b, c, d;
    a = 1;
    b = 1;
    c = 1;
    d = 1;
    printf(1, "TEST: %d %d %d %d\n", a, b, c, d);
    rec();
}

int
main(int argc, char *argv[]) {
    rec();
    exit();
    return 0;
}
