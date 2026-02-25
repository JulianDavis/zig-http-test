#include <stdio.h>

#include "http.h"

int main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: client <URL>\n");
        return 1;
    }

    http_get_request(argv[1]);
}