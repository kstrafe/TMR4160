#! /bin/bash

# Generer plots ved hjelp av gnuplot.

# Fjern først alle gamle bilder
if [ $(ls *.png 2>/dev/null | wc -l) -gt 0 ]; then rm *.png; fi

# Hent verdiene som Re og dt fra utputt (output)
. ../get_values.sh
get_values .

# Plot ett bilde
# $1: Plot.gnuplot fila
# $2: frame fila (203.image)
plot() {
	max_val=$(../get_max.awk $2)
	min_val=$(../get_min.awk $2)
	cur_time=$(../get_time.awk $2)
	frame=${2%%.image}
	# -e interpreter en linje i gnuplot, dermed kan vi sende inn variabler
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

# Se hvor mange images som finst. Dette blir brukt til å printe % ferdig
items=$(ls *.image | wc -l)
# Print ut hver 40. tegning
every=40
iter=0
for i in *.image; do
	# Kjør fire tråder parallelt, men vent dersom det går over denne verdien
	while [ $(jobs | wc -l) -ge 4 ]; do
		sleep 0.1
	done

	# Plot bildet i bakgrunnen
	plot $1 $i &

	# Beregn fremgangen, og print dersom den er en av "$every"
	iter=$((iter+1))
	if [ $(($iter % $every)) -eq "0" ]; then
		percent=$(LC_NUMERIC="en_US.UTF-8" printf %03.2f $(bc -l <<< 100*$iter.0/$items.0))
		echo "$percent% done with $1"
	fi
done

# Vent til siste jobb er ferdig
while [ $(jobs | wc -l) -gt 0 ]; do
	jobs > /dev/null
	sleep 0.1
done
