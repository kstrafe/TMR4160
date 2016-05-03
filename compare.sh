#! /bin/bash

# Sammenlign matlab utputt med skriptets utputt
function readMatrix {
	vel_u=$(cat "$2" | sed 's/,/ /g')
	IFS=' ' read -r -a $1 <<<$vel_u
}
readMatrix velocities_u "correctness/velocities_u"
readMatrix velocities_v "correctness/velocities_v"
readMatrix velocities_u_fortran "temp/velocities_u_fortran"
readMatrix velocities_v_fortran "temp/velocities_v_fortran"

iterator=0
length=${#velocities_u_fortran[@]}
while [ "$iterator" -lt "$length" ]; do
	echo $iterator, ${velocities_u_fortran[$iterator]}
	iterator=$((iterator+1))
done
