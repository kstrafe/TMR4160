reset

# wxt
# set terminal png size 350,262 enhanced font 'Verdana,10' persist
# png
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

#unset key
#unset tics
#unset colorbox
set border 0
set grid

#set palette defined ( \
#0 '#ffffff', \
#1 '#ffee00',\
#2 '#ff7000',\
#3 '#ee0000',\
#4 '#7f0000')
set palette rgbformulae 33,13,10

set xrange [-0.1:1.1]
set yrange [-0.1:1.1]
set cbrange [0:1]
#set xzeroaxis

h = 0.1
xf(phi) = h*cos(phi)
yf(phi) = h*sin(phi)

set label "dt: ".dt at graph 0.2,0.98 center font "Verdana,24"
set label "Max Speed: ".max_val at graph 0.5,0.98 center font "Verdana,24"
set label "Min Speed: ".min_val at graph 0.5,0.95 center font "Verdana,24"
set label "Frame: ".filename at graph 0.5,0.05 center font "Verdana,24"
set label "Time: ".time at graph 0.5,0.02 center font "Verdana,24"
set label "Reynolds: ".re at graph 0.1,0.02 center font "Verdana,24"
set label "Tmax: ".tmax at graph 0.1,0.05 center font "Verdana,24"
set label "n: ".n at graph 0.8,0.05 center font "Verdana,24"
set label "ideal dt: ".ideal_dt at graph 0.8,0.02 center font "Verdana,24"

plot filename.".image" \
	u ($1):($2):(xf($3)/3):(yf($3)/3):4 \
	with vectors head size 0.2,2,20 filled lc palette lw 5
