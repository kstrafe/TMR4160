#! /usr/bin/awk -f

/# MIN VALUE/ {
	print $4;
	exit 0;
}
