#! /bin/bash

rm output 2>/dev/null
for folder in *; do
	if [ -d "$folder" ]; then
		cd "$folder"
		./cleanup.sh
		cd ..
	fi
done
