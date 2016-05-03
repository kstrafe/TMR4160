#! /usr/bin/awk -f

# Dette skriptet henter fjerde kolonne fra en FS=' *' separert file

/# ideal dt/ {
	print $4;
	exit 0;
}
