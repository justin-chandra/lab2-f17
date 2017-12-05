
#include "types.h"
#include "user.h"

void rec(int n) {
    int a = n;
    int b = 1;
    float c = 2;
    char d = 's';
    int e = 3;
    a += 1;
    b += 2;
    c += 3;
    e += 4;
    d += 1;
    //printf(1, "hello world = %d \n", n);
    rec(a);
}
int
main(int argc, char *argv[]) {
    rec(1);
    exit();
    return 0;
}
/*
void print(){
    int a,b,c,d;
    a = 1;
    b = 1;
    c = 1;
    d = 1;
    printf(1,"hello world%d%d%d%d\n",a,b,c,d);
    print();
    
}
int main(int argc, char *argv[]){
    print();
    exit();
}
*/
