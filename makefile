all:
	cat main.f | sed 's/\t/  /g' > main2.f
	gfortran -std=f2008 -Wextra -Wall -Wtabs -ffree-form -pedantic main2.f -o nstokes 2>&1

run:
	$(MAKE) all
	./nstokes
