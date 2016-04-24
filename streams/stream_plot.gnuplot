#set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
#set output filename.".png"

reset
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

reset
set xrange [0:1]
set yrange [0:1]
unset key
set palette rgbformulae 33,13,10
p filename.".image" with image
# , 'cont.dat' w l lt -1 lw 1.5
