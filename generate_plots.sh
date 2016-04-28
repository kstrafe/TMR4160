#! /bin/bash

if [ $(ls *.png 2>/dev/null | wc -l) -gt 0 ]; then rm *.png; fi

. ../get_values.sh
get_values .

plot() {
	max_val=$(../get_max.awk $2)
	min_val=$(../get_min.awk $2)
	cur_time=$(../get_time.awk $2)
	frame=${2%%.image}
	gnuplot -e "filename='""$frame""'" \
		-e "max_val='"$max_val"'" \
		-e "min_val='"$min_val"'" \
		-e "time='"$cur_time"'" \
		-e "re='"$re"'" \
		-e "ideal_dt='"$ideal_dt"'" \
		-e "dt='"$dt"'" \
		-e "n='"$n"'" \
		-e "tmax='"$tmax"'" \
		$1
	mv $frame.png $(printf %08d $frame).png
}
items=$(ls *.image | wc -l)
iter=0
every=40
for i in *.image; do
	while [ $(jobs | wc -l) -ge 4 ]; do
		sleep 0.1
	done
	plot $1 $i &
	iter=$((iter+1))
	if [ $(($iter % $every)) -eq "0" ]; then
		percent=$(LC_NUMERIC="en_US.UTF-8" printf %03.2f $(bc -l <<< 100*$iter.0/$items.0))
		echo "$percent% done with $1"
	fi
done
while [ $(jobs | wc -l) -gt 0 ]; do
	jobs > /dev/null
	sleep 0.1
done
