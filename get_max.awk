#! /usr/bin/awk -f

/# MAX VALUE/ {
	print $4;
	exit 0;
}
