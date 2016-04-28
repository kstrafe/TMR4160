#! /usr/bin/awk -f

/# Re/ {
	print $3;
	exit 0;
}
