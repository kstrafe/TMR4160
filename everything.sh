#! /bin/bash

truncate -s 0 input
for i in $@; do
	echo $i >> input
done
./nstokes < input > output

if [ $? -ne 0 ]; then
	echo "Invalid input, try adjusting dt and n to be lower"
	exit 2
fi

cd velocities
./everything.sh

cd ../pressures
./everything.sh

cd ../streams
./everything.sh