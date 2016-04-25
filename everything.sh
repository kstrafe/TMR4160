#! /bin/bash

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

make
if [ $# -gt 1 ]; then
	truncate -s 0 input
	for i in $@; do
		echo $i >> input
	done
fi
./nstokes < input > output

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

# avconv -i 'concat:velocities/out.mpeg|pressures/out.mpeg|streams/out.mpeg' -c copy out.mpeg
