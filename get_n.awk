#! /usr/bin/awk -f

/# n/ {
	print $3;
	exit 0;
}
