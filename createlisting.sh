#! /bin/bash

# Genererer LaTeX listing slik at alt av den inkluderte koden blir autogenerert

interpolate() {
	caption=$(echo $1 | sed 's/\_/\\_/g')
	echo "\\lstinputlisting[caption={${caption##./}},breaklines=true,frame=single,language="$2"]{"$3"}"
}

language=( bash fortran matlab awk bash )
language_iter=0

for extension in sh f m awk gnuplot; do
	for filename in $(find -name '*.'"$extension"); do
		if [ "$filename" != "./temp/main2.f" ]; then
			interpolate "$filename" "${language[$language_iter]}" "$filename"
		fi
	done
	language_iter=$((language_iter+1))
done
interpolate makefile bash "makefile"
