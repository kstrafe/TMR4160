#! /bin/bash

if [ $(ls *.png | wc -l) -gt 0 ]; then rm *.png; fi

plot() {
	frame=${1%%.image}
	gnuplot -e "filename='""$frame""'" pressure_plot.gnuplot
	mv $frame.png $(printf %08d $frame).png
}
items=$(ls *.image | wc -l)
iter=0
for i in *.image; do
	while [ $(jobs | wc -l) -ge 8 ]; do
		sleep 0.1
	done
	plot $i &
	iter=$((iter+1))
	echo $(LC_NUMERIC="en_US.UTF-8" printf %03.2f $(bc -l <<< 100*$iter.0/$items.0))"% done"
done
while [ $(jobs | wc -l) -gt 1 ]; do
	sleep 0.1
done
