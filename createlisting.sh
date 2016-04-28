#! /bin/bash

interpolate() {
	caption=$(echo $1 | sed 's/\_/\\_/g')
	echo "\\lstinputlisting[caption={${caption##./}},breaklines=true,frame=single,language="$2"]{"$3"}"
}

for extension in sh f awk gnuplot; do
	for filename in $(find -name '*.'"$extension"); do
		if [ "$filename" != "./main2.f" ]; then
			interpolate "$filename" bash "$filename"
		fi
	done
done
