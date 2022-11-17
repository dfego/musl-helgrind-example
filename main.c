#include <pthread.h>
#include <stdio.h>

void *func1(void *arg) {
    return arg;
}

int main(void) {
    pthread_t handle1 = { 0 };
    pthread_create(&handle1, NULL, func1, NULL);
    pthread_join(handle1, NULL);
    return 0;
}
