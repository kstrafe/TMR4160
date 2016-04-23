#! /bin/bash

len=5
for i in *.image; do
	(
		frame=${i%%.image}
		gnuplot -e "filename='""$frame""'" speed_plot.gnuplot
		mv $frame.png $(printf %08d $frame).png
	) &
done
