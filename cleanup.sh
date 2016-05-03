#! /bin/bash

# Fjerne alle midlertidige filer som er generert av ulike skript.
# Kjører cleanup rekursivt

rm temp/* 2>/dev/null
rm output 2>/dev/null
for folder in *; do
	if [ -d "$folder" ]; then
		cd "$folder"
		./cleanup.sh
		cd ..
	fi
done

rm *.lol *.pdf *.toc *.aux *.log main2.f 2>/dev/null
rm report1.tex 2>/dev/null
