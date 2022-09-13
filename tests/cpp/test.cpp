#include <iostream>
#include <thread>
#include <future>

#include <unistd.h>

int main()
{
	std::cout << "Programs starts";
	auto fut = std::async(std::launch::async,[]{
		int i = 0;
		while(1) {
			i++;
			sleep(1);
		}
	});
	int j = 0;
	while(true) {
		j++;
		sleep(1);
	}
	fut.get();
	return 0;
}
