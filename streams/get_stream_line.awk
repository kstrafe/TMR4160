#! /usr/bin/awk -f

# Henter strømfunksjonen fra stdin og printer den til stdout

BEGIN { on = 0; number = 0; }
/# END STREAM LINE/ {
	number += 1;
	on = 0;
}
// {
	if (on == 1) {
		print;
	}
}
/# BEGIN STREAM LINE/ {
	on = 1;
	print "# Frame", number;
}
END { print "# Generated", number, "sequence(s)"; }
