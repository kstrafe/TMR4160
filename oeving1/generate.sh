echo "-10\n10\n10000" | ./ex1 > file.dat
# Part 2: 3)
echo "set terminal latex\nset out 'plot.tex'\nset key right top\nplot \"file.dat\" title \"\$x^2 sin(\\\\pi x)\$\"" | gnuplot
