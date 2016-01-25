echo "-10\n10\n10000" | ./ex1 > file.dat
echo "plot \"file.dat\"\npause 10" | gnuplot
