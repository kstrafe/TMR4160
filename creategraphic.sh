#! /bin/bash

# Lag en begin + includegraphics + end for hvert bilde i generated

for i in generated/*.png; do
	echo '\begin{center}'
	echo '\includegraphics[width=7in]{'${i}'}'
	echo "$i"
	echo '\end{center}'
done
