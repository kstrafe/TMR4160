#! /bin/bash

if [ $(ls *.png 2>/dev/null | wc -l) -gt 0 ]; then rm *.png; fi

plot() {
	frame=${1%%.image}
	gnuplot -e "filename='""$frame""'" speed_plot.gnuplot
	mv $frame.png $(printf %08d $frame).png
}
items=$(ls *.image | wc -l)
iter=0
every=40
for i in *.image; do
	while [ $(jobs | wc -l) -ge 4 ]; do
		sleep 0.1
	done
	plot $i &
	iter=$((iter+1))
	if [ $(($iter % $every)) -eq "0" ]; then
		echo $(LC_NUMERIC="en_US.UTF-8" printf %03.2f $(bc -l <<< 100*$iter.0/$items.0))"% done with velocity plotting"
	fi
done
while [ $(jobs | wc -l) -gt 0 ]; do
	jobs > /dev/null
	sleep 0.1
done
