#! /usr/bin/awk -f

/# TIME/ {
	print $3;
	exit 0;
}
