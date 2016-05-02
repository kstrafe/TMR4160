#! /usr/bin/awk -f

# Dette skriptet henter fjerde kolonne fra en FS=' *' separert file
/# MAX VALUE/ {
	print $4;
	exit 0;
}
