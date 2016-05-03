#! /usr/bin/awk -f

# Dette skriptet henter tredje kolonne fra en FS=' *' separert file

/# dt/ {
	print $3;
	exit 0;
}
