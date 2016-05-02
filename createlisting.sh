#! /bin/bash

# Genererer LaTeX listing slik at alt av den inkluderte koden blir autogenerert
interpolate() {
	caption=$(echo $1 | sed 's/\_/\\_/g')
	echo "\\lstinputlisting[caption={${caption##./}},breaklines=true,frame=single,language="$2"]{"$3"}"
}

for extension in sh f m awk gnuplot; do
	for filename in $(find -name '*.'"$extension"); do
		if [ "$filename" != "./main2.f" ]; then
			interpolate "$filename" bash "$filename"
		fi
	done
done
