#! /bin/bash

# Sammenlign matlab utputt med skriptets utputt
# Dette skriptet printer ut den absolutte og relative feilen mellom fortran og matlab

# Les en matrise til en array, erstatt alle kommaer med mellomrom
function readMatrix {
	vel_u=$(cat "$2" | sed 's/,/ /g')
	IFS=' ' read -r -a $1 <<<$vel_u
}

# Fjern alle + symboler (ellers gir det feil i bc med 10^(+0))
function replacePlus {
	echo $1 | sed s/+//g
}

# Finn og print alle differanser, både absolutt og relative
function computeDifferences {
	echo "# BEGIN $3"
	echo "# 1" "$1"
	echo "# 2" "$2"

	# Hent matrisene
	readMatrix matlab_speeds "$1"
	readMatrix fortran_speeds "$2"

	iterator=0
	length=${#matlab_speeds[@]}
	other_length=${#fortran_speeds[@]}
	awkscript='{ if (NF == 2) printf "%s*10^(%s)", $1, $2; else print; }'
	while [ "$iterator" -lt "$length" ] && [ "$iterator" -lt "$other_length" ]; do
		fortran=${fortran_speeds[$iterator]}

		# Fjern vitenskaplig notasjon fra elementet (bc klarer ikke å parse det)
		fortran=$(echo $fortran | awk -F'E' "$awkscript")
		matlab=${matlab_speeds[$iterator]}
		matlab=$(echo $matlab | awk -F'e' "$awkscript")

		# Fjern pluss tegnet
		fortran=$(replacePlus $fortran)
		matlab=$(replacePlus $matlab)

		# Beregn absolutt og relativ feil
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
