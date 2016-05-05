#! /usr/bin/awk -f

function abs(value) { return value > 0 ? value : -value; }
BEGIN { abs_avg = 0; abs_hit = 0; rel_avg = 0; rel_hit = 0; }
/Absolute Error/ { abs_avg += abs($4); ++abs_hit; }
/Relative Error/ { rel_avg += abs($4); ++rel_hit; }
END {
	print "Avg. Abs. Err.:", abs_avg / abs_hit;
	print "Avg. Rel. Err.:", rel_avg / rel_hit;
}
