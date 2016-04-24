#! /bin/bash

truncate -s 0 input
for i in $@; do
	echo $i >> input
done
./nstokes < input > output

cd velocities
./everything.sh

cd ../pressures
./everything.sh

cd ../streams
./everything.sh
