reset

# wxt
# set terminal png size 350,262 enhanced font 'Verdana,10' persist
# png
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

unset key
unset tics
unset colorbox
set border 0

set palette defined ( \
0 '#ffffff', \
1 '#ffee00',\
2 '#ff7000',\
3 '#ee0000',\
4 '#7f0000')

set xrange [0:1]
set yrange [0:1]
set cbrange [0:1]
set xzeroaxis

h = 0.1
xf(phi) = h*cos(phi/180.0*pi)
yf(phi) = h*sin(phi/180.0*pi)

plot filename.".image" \
	u ($1):($2):(xf($3)/3):(yf($3)/3):4 \
	with vectors head size 0.2,2,20 filled lc palette lw 5
