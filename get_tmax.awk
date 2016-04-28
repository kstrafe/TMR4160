#! /usr/bin/awk -f

/# tmax/ {
	print $3;
	exit 0;
}
