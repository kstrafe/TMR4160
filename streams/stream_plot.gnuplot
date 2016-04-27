#set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
#set output filename.".png"

reset
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

reset
set xrange [-0.1:1.1]
set yrange [-0.1:1.1]
unset key
set palette rgbformulae 33,13,10
set label "Max Stream: ".max_val at graph 0.5,0.98 center font "Verdana,24"
set label "Min Stream: ".min_val at graph 0.5,0.95 center font "Verdana,24"
p filename.".image" with image
# , 'cont.dat' w l lt -1 lw 1.5
