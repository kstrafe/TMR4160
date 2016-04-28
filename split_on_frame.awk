#! /usr/bin/awk -f

BEGIN { number = 0; }
/# Frame/ {
	number += 1;
}
// {
	print $0 > number".image";
}
