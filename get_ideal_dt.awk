#! /usr/bin/awk -f

/# ideal dt/ {
	print $4;
	exit 0;
}
