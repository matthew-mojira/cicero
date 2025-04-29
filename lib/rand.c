#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define RANGE 500

int main(int argc, char **argv) {
	if (argc == 2) {
		int nums = atoi(argv[1]);
		srand(time(NULL));

		printf("[");
		while (nums --> 0) {
			printf("%d", rand() % RANGE);
			if (nums > 0) putchar(' ');
		}

		printf("]");
		
		return 0;
	} else {
		return 1;
	}
}
