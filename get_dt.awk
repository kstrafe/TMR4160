#! /usr/bin/awk -f

/# dt/ {
	print $3;
	exit 0;
}
