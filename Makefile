.PHONY: tests bin
tests:
	nvim --headless -c "PlenaryBustedDirectory tests/" | \
	sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
bin:
	gcc -g -o tests/c/test tests/c/test.c
	g++ -g -o tests/cpp/test tests/cpp/test.cpp -lpthread

