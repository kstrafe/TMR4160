#! /bin/bash

# Kjør skriptet for hver inputt fil
# Lagre alle videoer med ulik navn i temp

# Drep alle barn dersom dette skriptet får sigint eller lignende
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

function move {
	mv "$1"/out.mov generated/"${2#inputs/}"_"$1".mov
}

function moveLastImage {
	last=$(echo "$1"/*.png | sort -h | rev | cut -d' ' -f 1 | rev)
	mv "$last" generated/"${2#inputs/}"_"$1".png
}

for input in $@; do
	./everything_no_vlc.sh "$input"
	move velocities "$input"
	move pressures "$input"
	move streams "$input"

	moveLastImage velocities "$input"
	moveLastImage pressures "$input"
	moveLastImage streams "$input"
done
