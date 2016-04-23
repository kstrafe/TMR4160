reset

set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output 'pressure.png'

set palette rgbformulae 22,13,10
set xrange [0:1]
set yrange [0:1]
set isosample 250, 250
splot 'output'
