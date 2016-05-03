#! /usr/bin/awk -f

# Denne filen gjør matlab dlmwrite matriser om til en hastighets 'image' fil

BEGIN { FS = ","; inside = 0; }
/# BEGIN VELOCITY U/ { inside = 1; next; }
/# END VELOCITY U/ { inside = 0; next; }
/# BEGIN VELOCITY V/ { inside = 2; next; }
/# END VELOCITY V/ { inside = 0; next; }
!/#/ {
	if (inside == 1) { print | "cat > temp/velocities_u_fortran"; }
	if (inside == 2) { print | "cat > temp/velocities_v_fortran"; }
}
