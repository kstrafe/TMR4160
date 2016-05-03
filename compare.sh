#! /bin/bash

# Sammenlign matlab utputt med skriptets utputt
# Dette skriptet printer ut den absolutte og relative feilen mellom fortran og matlab

function readMatrix {
	vel_u=$(cat "$2" | sed 's/,/ /g')
	IFS=' ' read -r -a $1 <<<$vel_u
}

function replacePlus {
	echo $1 | sed s/+//g
}

function computeDifferences {
	echo "# BEGIN $3"
	echo "# 1" "$1"
	echo "# 2" "$2"
	readMatrix matlab_speeds "$1"
	readMatrix fortran_speeds "$2"

	max_absolute=0
	max_relative=0

	iterator=0
	length=${#matlab_speeds[@]}
	while [ "$iterator" -lt "$length" ]; do
		fortran=${fortran_speeds[$iterator]}
		fortran=$(echo $fortran | awk -F'E' '{ printf "%s*10^(%s)", $1, $2; }')
		matlab=${matlab_speeds[$iterator]}
		matlab=$(echo $matlab | awk -F'e' '{ if (NF==2) printf "%s*10^(%s)", $1, $2; else print; }')
		fortran=$(replacePlus $fortran)
		matlab=$(replacePlus $matlab)

		absolute=$(echo "$fortran-($matlab)" | bc -l)
		relative=$(echo "1-($fortran/($matlab))" | bc -l)

		echo Absolute Error = $absolute
		echo Relative Error = $relative

		iterator=$((iterator+1))
	done
	echo "# END $3"
}

computeDifferences "correctness/velocities_u" "temp/velocities_u_fortran" "Differences in U"
computeDifferences "correctness/velocities_v" "temp/velocities_v_fortran" "Differences in V"
