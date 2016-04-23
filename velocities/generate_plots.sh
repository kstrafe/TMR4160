#! /bin/bash

plot() {
	frame=${1%%.image}
	gnuplot -e "filename='""$frame""'" speed_plot.gnuplot
	mv $frame.png $(printf %08d $frame).png
	echo $1
}
for i in *.image; do
	while [ $(jobs | wc -l) -ge 8 ]; do
		sleep 1
	done
	plot $i &
done
