#! /bin/sh

filename=$1
begin_line=$2
end_line=$3

if [ $# -gt 2 ]; then
	cat $filename | head -n $end_line | head -n $(($end_line - $begin_line)) \
		| sed "s/\t/  /g"
else
	cat $filename | sed "s/\t/  /g"
fi
