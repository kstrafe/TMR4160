#! /usr/bin/awk -f

BEGIN { on = 0; number = 0; }
/# END PRESSURE FIELD/ {
	number += 1;
	on = 0;
}
// {
	if (on == 1) {
		print;
	}
}
/# BEGIN PRESSURE FIELD/ {
	on = 1;
	print "# Frame", number;
}
END { print "# Generated", number, "sequence(s)"; }
