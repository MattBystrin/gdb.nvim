.PHONY: tests bin
bin:
	gcc -g -o tests/c/test tests/c/test.c

tests:
	nvim --headless -c "PlenaryBustedDirectory tests/"
