#! /bin/bash

# Kjører hele simulasjonen med resultat videoer
depend() {
	command -v $1 >/dev/null 2>&1 || {
		echo "This script requires $1, but it's not installed. Aborting." >&2
		exit 1
	}
}

depend avconv
depend awk
depend cp
depend find
depend gfortran
depend gnuplot
depend ls
depend make
depend mv
depend rm
depend vlc
depend wc

mkdir temp

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

make
if [ $# -gt 1 ]; then
	truncate -s 0 input
	for i in $@; do
		echo $i >> input
	done
fi
echo "Running the simulation, hold on..."
./nstokes < input > output
echo "Done with the simulation, processing data..."

if [ $? -ne 0 ]; then
	echo "Invalid input, try adjusting dt and n to be lower"
	exit 2
fi

cd velocities
./everything.sh &

cd ../pressures
./everything.sh &

cd ../streams
./everything.sh

while [ $(jobs | wc -l) -gt 0 ]; do
	jobs > /dev/null
	sleep 0.1
done

cd ..

printf '%s' "Do you want to compare the velocities with matlab 12-20-12-20 result? (y/n) (n):"
read ans
if [ "$ans" = "y" ]; then
	echo Computing differences with conventional 12-20-12-20 matlab answer
	./matrix_to_image.awk output
	./compare
fi

vlc $(find -name '*.mov')
