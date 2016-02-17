all:
	gfortran -std=f2008 -Wextra -Wall -Wtabs -ffree-form -pedantic main.f 2>&1 | grep -v 'Warning: Nonconforming tab character at ([0-9]\+)'
