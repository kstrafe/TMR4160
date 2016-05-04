all:
	cat main.f | sed 's/\t/  /g' > temp/main2.f
	gfortran -std=f2008 -Wextra -Wall -Wtabs -ffree-form -pedantic temp/main2.f -o nstokes 2>&1

run:
	$(MAKE) all
	./nstokes

doc:
	./cleanup.sh
	m4 report.tex > report.1.tex
	pdflatex report.1.tex
	pdflatex report.1.tex  # Flere ganger for å bygge opp table of contents
	evince report.1.pdf
