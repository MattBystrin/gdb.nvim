.PHONY: tests bin
tests:
	nvim --headless -c "PlenaryBustedDirectory tests/" | \
	sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
bin:
	gcc -g -o tests/intgr/c/test tests/intgr/c/test.c
	g++ -g -o tests/intgr/cpp/test tests/intgr/cpp/test.cpp -lpthread

