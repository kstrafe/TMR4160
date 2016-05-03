#! /usr/bin/awk -f

# Dette skriptet henter ut flow verdien fra utputt

/# flow/ {
	print $3;
	exit;
}
