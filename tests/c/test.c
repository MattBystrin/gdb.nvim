#include <stdlib.h>
#include <stdio.h>
#include <time.h>

struct item {
	char *name;
	double price;
};

struct storage {
	struct item item;
	int count;
};

void dummy_func()
{
	volatile int tmp = 0;
	tmp += 22;
	return;
}

int some_func(int arg1, int arg2)
{
	int sum = 0;
	for (int i = 0; i < arg1; i++) {
		sum += arg2;
	}
	return sum;
}

int main()
{
	struct item item = {
		.name = "Resistor",
		.price = 10.6
	};
	struct storage s = {
		.item = item,
		.count = 1
	};
	srand(time(NULL));
	printf("Starting random test debug\n");
	int ret = some_func(rand() % 20, rand() % 10);
	if (ret > 20)
		printf("Big sum %d\n", ret);
	else
		printf("Low sum %d\n", ret);
	int i = 0;
	while(1) {
		i++;
	}
	return 0;
}
