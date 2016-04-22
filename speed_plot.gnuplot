#!/usr/bin/gnuplot
#
# Plotting a vector field from a data file
#
# AUTHOR: Hagen Wierstorf

reset

# wxt
# set terminal png size 350,262 enhanced font 'Verdana,10' persist
# png
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output 'vector_fields1.png'

unset key
unset tics
unset colorbox
set border 0

set palette defined ( 0 '#ffffff', \
1 '#ffee00',\
2 '#ff7000',\
3 '#ee0000',\
4 '#7f0000')

set xrange [0:1]
set yrange [0:1]
set cbrange [0:1]

# functions to calculate the arrow offsets
h = 0.1 # vector size
xf(phi) = h*cos(phi/180.0*pi)
yf(phi) = h*sin(phi/180.0*pi)

plot 'output' \
	u ($1):($2):(xf($3)/3):(yf($3)/3):4 \
	with vectors head size 0.1,2,60 filled lc palette
