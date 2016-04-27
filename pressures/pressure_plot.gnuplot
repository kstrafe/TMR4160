reset
set terminal pngcairo size 2000,2000 enhanced font 'Verdana,10'
set output filename.".png"

# f(x,y)=sin(1.3*x)*cos(.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x)
# set xrange [-5:5]
# set yrange [-5:5]
# set isosample 250, 250
# set table 'test.dat'
# splot f(x,y)
# unset table
#
# set contour base
# set cntrparam level incremental -3, 0.5, 3
# unset surface
# set table 'cont.dat'
# splot f(x,y)
# unset table

reset
set xrange [-0.1:1.1]
set yrange [-0.1:1.1]
unset key
set palette rgbformulae 33,13,10
p filename.".image" with image
# , 'cont.dat' w l lt -1 lw 1.5
