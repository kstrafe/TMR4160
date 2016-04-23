set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

reset
set hidden3d
set xrange [0:1]
set yrange [0:1]
unset key
set palette rgbformulae 33,13,10
splot filename.'.image' with lines
