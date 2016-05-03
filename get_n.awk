#! /usr/bin/awk -f

# Dette skriptet henter tredje kolonne fra en FS=' *' separert file

/# n/ {
	print $3;
	exit 0;
}
