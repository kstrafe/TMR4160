#! /bin/bash

# Fjerne alle midlertidige filer som er generert av ulike skript.
# Kjører cleanup rekursivt

rm temp/* 2>/dev/null
rm output 2>/dev/null
for folder in *; do
	if [ -d "$folder" ]; then
		cd "$folder"
		if [ -f cleanup.sh ]; then
			./cleanup.sh
		fi
		cd ..
	fi
done

rm *.lol *.pdf *.toc *.aux *.log main2.f 2>/dev/null
rm report1.tex 2>/dev/null
git filter-branch --index-filter 'git update-index --remove $(find -name "*.png")' 8eae723464da6362414bec890600f417fbe45ef4 HEAD
true
