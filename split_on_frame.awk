#! /usr/bin/awk -f

# Splitter hver frame til egen fil

BEGIN { number = 0; }
/# Frame/ {
	number += 1;
}
// {
	print $0 > number".image";
}
