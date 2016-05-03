#! /bin/bash

# Kjører hele simulasjonen med resultat videoer, og avviksberegning

depend() {
	command -v $1 >/dev/null 2>&1 || {
		echo "This script requires $1, but it's not installed. Aborting." >&2
		exit 1
	}
}

# Sjekk om vi har alle programmer som er nødvendige
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

# Forsikre at temp mappa eksisterer
if ! [ -d temp ]; then
	mkdir temp
fi

# Drep alle barn dersom dette skriptet får sigint eller lignende
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Forsikre at den nyeste versjonen er laget
make

# Print alle input variabler til en fil, som pipes til nstokes
if [ $# -gt 1 ]; then
	truncate -s 0 input
	for i in $@; do
		echo $i >> input
	done
fi
echo "Running the simulation, hold on..."
./nstokes < input > output
echo "Done with the simulation, processing data..."

# Dersom nstokes feilet, avslutter vi skriptet. Det skjer hvis vi får NaN for eksempel.
if [ $? -ne 0 ]; then
	echo "Invalid input, try adjusting dt and n to be lower"
	exit 2
fi

# Kjør plotting parallellt
cd velocities
./everything.sh &

cd ../pressures
./everything.sh &

cd ../streams
./everything.sh

# Vent til plottingen er ferdig
while [ $(jobs | wc -l) -gt 0 ]; do
	jobs > /dev/null
	sleep 0.1
done

cd ..

# Beregn den absolutte og relative forskjellen fra matlab
# Det blir store avvik dersom vi ikke bruker 12-20-12-20 boksen, det er fordi
# matlab bare ble kjørt med 12-20-12-20 boksen. Vi har ikke annet å sammenligne med
echo Computing differences with conventional 12-20-12-20 matlab answer
./matrix_to_image.awk output
./compare > temp/differences

# Kjør vlc (eller erstatt med en annen video-viewer) på alle video filer
vlc $(find -name '*.mov')
