all:
	cat main.f | sed 's/\t//g' > main2.f
	gfortran -std=f2008 -Wextra -Wall -Wtabs -ffree-form -pedantic main2.f 2>&1

vis:
	gnuplot speed_plot.gnuplot
	eog vector_fields1.png
