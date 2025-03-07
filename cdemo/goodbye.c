#include <stdio.h>
#include <stdlib.h>

#include "../include/mymessage.h"

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Error: Expected a single positional argument\n");
        return 1;
    }

    unsigned short init_status = mymessage_init();
    if (init_status != 0) {
        printf("Error: Failed to initialize mymessage\n");
        exit(1);
    }

    printf("Message: %s\n", mymessage_getMessage("goodbye", argv[1]));
    mymessage_deinit();
}
