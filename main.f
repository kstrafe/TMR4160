program navier
	! Fjern automatiske indeks variabler
	implicit none

	! Sett reynolds tall, tids-endingen, og tids-steppet
	! dt må settes selv om den settes senere, ellers får vi en intern
	! kompilator feil
	real(8) :: Re, dt, tmax

	! Variabler til stabilitets beregning
	real(8) :: h, beta, ideal, omega
	real(8), dimension(9) :: nn = [0, 5, 10, 20, 30, 40, 60, 100, 500]
	real(8), dimension(9) :: cc = [1.7, 1.78, 1.86, 1.92, 1.95, 1.96, 1.97, 1.98, 1.99]

	! Iterator hjelpere til time steppet
	real(8) :: t, div, delp

	! Iteratorer
	integer :: i, j, iter

	! Maks verdi på iterasjonen og feil endings flagget
	integer :: itmax = 300, iflag = 0

	! Grid størrelse
	integer :: n

	! Indeksene for boksen som står i strømmen
	integer :: top, bottom, left, right, height

	! Maskin epsilon
	real(8) :: epsi = 1e-6

	! Hastighet, trykk, og strømningsfelt
	real(8), allocatable :: u(:,:), v(:,:), p(:,:), psi(:,:)

	! Midlertidige verdier for løsningen av Navier-Stokes
	real(8) :: fux, fuy, fvx, fvy, visu, visv

	! Min og maks verdier for printing
	real(8) :: max_speed, min_speed, current_speed, angle
	real(8) :: max_pressure, min_pressure, current_pressure
	real(8) :: max_streamline, min_streamline, current_stream

	! Få grid størrelsen
	n = int(query('# Enter n (0 will default to 30): ', dble(30), epsi))

	! Alloker minne til strømfunksjonens verdier
	allocate(psi(n+1,n+1))
	psi = 0

	! Beregn grensene til boksen
	bottom = int((n+2)/4 + (n+2)/8);
	height = int((n+2)/4);
	top = bottom + height;
	left = bottom;
	right = top;

	! Opprett hastighetsfelt og trykkfelt
	allocate(u(n+2,n+2))
	u = 0
	v = u
	p = u

	! Få reynolds tallet i strømningen
	Re = query('# Enter Re (0 will default to 100): ', dble(100), epsi)

	! Få ut tidsskrittet
	dt = query('# Enter dt (0 will default to 0.01): ', dble(0.01), epsi)

	! Få ut den endelige tiden
	tmax = query('# Enter tmax (0 will default to 10): ', dble(10), epsi)

	! Beregn stabilitetsverdier
	omega = interp1(nn, cc, dble(n), 9)
	h = 1/real(n)
	beta = omega*h**2/(4*dt)

	! Varsle dersom metoden kan være ustabil
	ideal = min(h, Re*h**2.0/4.0, 2.0/Re)
	if (dt > ideal) then
		print *, '# Varsel! dt bør være mindre enn ', ideal
	endif

	! Selve navier stokes løseren
	t = 0.0
	do while (t <= tmax)
		i = 2
		do while (i <= n+1)
			j = 2
			do while (j <= n+1)
				fux=((u(i,j)+u(i+1,j))**2-(u(i-1,j)+u(i,j))**2)*0.25/h
				fuy=((v(i,j)+v(i+1,j))*(u(i,j)+u(i,j+1))-(v(i,j-1)+v(i+1,j-1))*(u(i,j-1)+u(i,j)))*0.25/h
				fvx=((u(i,j)+u(i,j+1))*(v(i,j)+v(i+1,j))-(u(i-1,j)+u(i-1,j+1))*(v(i-1,j)+v(i,j)))*0.25/h
				fvy=((v(i,j)+v(i,j+1))**2-(v(i,j-1)+v(i,j))**2)*0.25/h
				visu=(u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4.0*u(i,j))/(Re*h**2)
				visv=(v(i+1,j)+v(i-1,j)+v(i,j+1)+v(i,j-1)-4.0*v(i,j))/(Re*h**2)
				u(i,j)=u(i,j)+dt*((p(i,j)-p(i+1,j))/h-fux-fuy+visu)
				v(i,j)=v(i,j)+dt*((p(i,j)-p(i,j+1))/h-fvx-fvy+visv)
				j = j + 1
			enddo
			i = i + 1
		enddo

		do iter = 1, itmax
			! Venstre og høyre rand
			do j = 1, n+2
				u(1,j) = 0.1
				v(1,j) = -v(2,j)
				u(n+1,j) = 0.1
				v(n+2,j) = -v(n+1,j)
			enddo
			! Topp og bunn rand
			do i = 1, n+2
				v(i,n+1) = 0.0
				v(i,1) = 0.0
				u(i,n+2) = -u(i,n+1)
				u(i,1) = -u(i,2)
			enddo

			! Venstre og høyre kant av boksen
			do j = bottom, top
				u(left,j)=0.0;
				v(left,j)=-v(left+1,j);
				u(right,j)=0.0;
				v(right+1,j)=-v(right,j);
			enddo
			! Topp og bunnpunkt av boksen
			do i = left, right
				v(i,top)=0.0;
				v(i,bottom)=0.0;
				u(i,top+1)=-u(i,top);
				u(i,bottom)=-u(i,bottom+1);
			enddo

			! Sett ferdig flagget til null
			iflag = 0
			do j = 2, n+1
				do i = 2, n+1
					div = (u(i,j)-u(i-1,j))/h+(v(i,j)-v(i,j-1))/h
					if (abs(div) >= epsi) then
						iflag = 1
					endif
					delp = -beta*div
					p(i,j) = p(i,j)+delp
					u(i,j) = u(i,j)+delp*dt/h
					u(i-1,j) = u(i-1,j)-delp*dt/h
					v(i,j) = v(i,j)+delp*dt/h
					v(i,j-1) = v(i,j-1)-delp*dt/h
				enddo
			enddo
			if (iflag == 0) then
				exit
			endif
		enddo
		if (iter >= itmax) then
			 print *, '# Warning! Time t= ', t, ' iter= ', iter,' div= ', div
		else
				write(*,*) '# Time t= ', t, ' iter= ', iter
		endif
		t = t + dt

		! Beregn minste hastighet for denne framen
		min_speed = sqrt(((v(2,1)+v(2,2))/2)**2 + ((u(1,2)+u(2,2))/2)**2)
		do i = 2, n
			do j = 1, n
				min_speed = min(sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2), min_speed)
			enddo
		enddo
		! Beregn største hastighet for denne framen
		max_speed = sqrt(((v(2,1)+v(2,2))/2)**2 + ((u(1,2)+u(2,2))/2)**2)-min_speed
		do i = 2, n
			do j = 1, n
				max_speed = max(sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2)-min_speed, max_speed)
			enddo
		enddo

		! Print ut vektor feltet
		print *, '# BEGIN VECTOR FIELD'
		print *, '# MAX VALUE', max_speed
		print *, '# MIN VALUE', min_speed
		do i = 1, n
			do j = 1, n
				current_speed = sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2) / max_speed
				angle = 180/(355/113)*atan2((v(i+1,j)+v(i+1,j+1))/2, (u(i,j+1)+u(i+1,j+1))/2)
				print *, real(i-1)/(n-1), real(j-1)/(n-1), angle, current_speed
				if (isNan(angle)) then
					stop 2
				endif
			enddo
		enddo
		print *, '# END VECTOR FIELD'

		! Beregn det minste trykket for denne framen
		min_pressure = p(2,2)
		do i = 1, n
			do j = 1, n
				min_pressure = min(p(i+1,j+1), min_pressure)
			enddo
		enddo
		! Beregn det maksimale trykket for denne framen
		max_pressure = p(2,2) - min_pressure
		do i = 1, n
			do j = 1, n
				max_pressure = max(p(i+1,j+1) - min_pressure, max_pressure)
			enddo
		enddo

		! Print trykkfeltet
		print *, '# BEGIN PRESSURE FIELD'
		print *, '# MAX VALUE', max_pressure
		print *, '# MIN VALUE', min_pressure
		do i = 1, n
			do j = 1, n
				current_pressure = (p(i+1,j+1)-min_pressure)/max_pressure
				print *, real(i-1)/(n-1), real(j-1)/(n-1), current_pressure
				if (isNan(current_pressure)) then
					stop 2
				endif
			enddo
		enddo
		print *, '# END PRESSURE FIELD'

		! Beregn strømningsfunksjonen
		do i = 2, n+1
			psi(i, 1) = psi(i-1, 1) - v(i, 1) * h;
		enddo
		do i = 1, n+1
			do j = 2, n+1
				psi(i, j) = psi(i, j-1) + u(i, j) * h;
			enddo
		enddo

		! Finn den minste verdien av strømfunksjonen
		min_streamline = psi(1, 1);
		do i = 1, n+1
			do j = 1, n+1
				min_streamline = min(min_streamline, psi(i, j))
			enddo
		enddo

		! Finn den største verdien av strømfunksjonen
		max_streamline = psi(1, 1) - min_streamline;
		do i = 1, n+1
			do j = 1, n+1
				max_streamline = max(max_streamline, psi(i, j)-min_streamline)
			enddo
		enddo

		! Print ut strømfunksjonen
		print *, '# BEGIN STREAM LINE'
		print *, '# MAX VALUE', max_streamline
		print *, '# MIN VALUE', min_streamline
		do i = 1, n+1
			do j = 1, n+1
				current_stream = (psi(i, j) - min_streamline) / max_streamline
				print *, real(i-1)/n, real(j-1)/n, current_stream
				if (isNan(current_stream)) then
					stop 2
				endif
			enddo
		enddo
		print *, '# END STREAM LINE'

	enddo

contains

	!   --------------------------------------------------------------------
	!     Function                 closestIndex                     No.: 0
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Finn den nærmeste indeks i et monotont stigende array.
	!   Metode :
	!   Iterer gjennom arrayet. Den posisjonen som inneholder det
	!   minste avviket velges. Denne metoden kan gjøres kjappere
	!   ved bruk av binærsøk.
	!
	!   Kall sekvens .......................................................
	!
	!    closestIndex(array, arsize, desired)
	!
	!   Parametre:
	!   Navn           I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   closestIndex   O    I       Index til nærmeste tall
	!   array          I    [I]     Monotont sortert array der tallet ligger
	!   arsize         I    I       Størrelsen på arrayet
	!   desired        I    R       Ønsket tall som indeksen skal være nærmest
	!
	!     I N T E R N E   V A R I A B L E :
	!     min_distance        Holder rede på den minimale distansen
	!     i                   Lagrer den nærmeste indeksen
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.02.17 / 1.0
	!
	! **********************************************************************
	!
	integer function closestIndex(array, arsize, desired)
		! Let x be a monotonically increasing array
		! Val is the value to find the closest index to
		implicit none
		real(8), dimension(:), intent(in) :: array
		integer, intent(in) :: arsize
		integer :: i
		real(8), intent(in) :: desired
		real(8) :: min_distance, distance

		closestIndex = 1
		if (arsize <= 0) then
			closestIndex = -1
			return
		end if
		min_distance = abs(array(1)-desired)

		do i = 2, arsize, 1
			distance = abs(array(i)-desired)
			if (distance < min_distance) then
				min_distance = distance
				closestIndex = i
			endif
		end do
	end

	!   --------------------------------------------------------------------
	!     Function                 nextClosestIndex                 No.: 1
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Finn den nest nærmeste indeks i et monotont stigende array.
	!   Metode :
	!   Iterer gjennom arrayet. Den posisjonen som inneholder det
	!   nest minste avviket velges.
	!
	!   Kall sekvens .......................................................
	!
	!    nextClosestIndex(array, arsize, closest, desired)
	!
	!   Parametre:
	!   Navn               I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   nextClosestIndex   O    I       Index til nærmeste tall
	!   array              I    [I]     Monotont sortert array der tallet ligger
	!   arsize             I    I       Størrelsen på arrayet
	!   closest            I    I       Nærmeste index som allerede er funnet
	!   desired            I    R       Ønsket tall som indeksen skal være nærmest
	!
	!     I N T E R N E   V A R I A B L E :
	!     next_closest        Lagrer den indeksen som tilsvarer nest minste verdi
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.02.17 / 1.0
	!
	! **********************************************************************
	!
	integer function nextClosestIndex(array, arsize, closest, desired)
		real(8), dimension(:), intent(in) :: array
		integer, intent(in) :: arsize
		integer, intent(in) :: closest
		real(8), intent(in) :: desired
		real(8) :: next_closest
		! Assume arrays are 1-indexed
		if (arsize <= 1) then
			nextClosestIndex = -1
		endif

		if (closest < arsize) then
			if (closest == 1) then
				nextClosestIndex = 2
			else
				next_closest = abs(array(closest+1)-desired)
			if (next_closest < abs(array(closest-1)-desired)) then
				nextClosestIndex = closest+1
			else
				nextClosestIndex = closest-1
			endif
		endif
		else
			nextClosestIndex = closest - 1
		endif
	end

	!   --------------------------------------------------------------------
	!     Function                 interp1                          No.: 2
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Linaer interpolasjon av en posisjon innen en rekke tall
	!   Metode :
	!   Finn venstre og høyre nabo til punktet, og interpoler via
	!   dy/dx * avstand_fra_venstre + y_venstre
	!
	!   Kall sekvens .......................................................
	!
	!    interp1(x, y, z, arsize)
	!
	!   Parametre:
	!   Navn           I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   interp1        O    R(8)     Den interpolerte verdien
	!   x              I    [R(8)]   Indeksene til array y
	!   y              I    [R(8)]   Verdiene som skal interpoleres
	!   z              I    R(8)     Interpolasjons punkt
	!   arsize         I    I        Størrelsen av hver array
	!
	!     I N T E R N E   V A R I A B L E :
	!     next_closest        Lagrer den indeksen som tilsvarer nest minste verdi
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.02.17 / 1.0
	!
	! **********************************************************************
	!
	real(8) function interp1(x, y, z, arsize)
		implicit none
		real(8), dimension(:), intent(in) :: x, y
		real(8), intent(in) :: z
		real(8) :: xdiff, ydiff, zdiff
		integer, intent(in) :: arsize
		integer :: closest, next_closest, mini, maxi

		closest = closestIndex(x, arsize, z)
		next_closest = nextClosestIndex(x, arsize, closest, z)
		mini = min(closest, next_closest)
		maxi = max(closest, next_closest)
		xdiff = x(maxi) - x(mini)
		ydiff = (y(maxi) - y(mini)) / xdiff
		zdiff = z - x(mini)
		! We create a line segment and add the gradient
		interp1 = y(mini) + zdiff * ydiff
		return
	end

	!   --------------------------------------------------------------------
	!     Function                 isNan                            No.: 3
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Finne ut om en float/double er en IEEE754 NaN
	!   Metode :
	!   Bruke IEEE754 sin definisjon at tallet er ulik seg selv:
	!   (x != x) == true
	!
	!   Kall sekvens .......................................................
	!
	!    isNan(a)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   isNan       O    L(4)    False/True om verdien er NaN eller ikke
	!   a           I    R(8)    Verdien som skal sjekkes
	!
	!     I N T E R N E   V A R I A B L E :
	!       Ingen
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.19 / 1.0
	!
	! **********************************************************************
	!
	logical(4) function isNan(a)
		implicit none
		real(8), intent(in) :: a
		isNan = a /= a
	end

	real(8) function query(question, defaulting, epsi)
		implicit none
		character(len=*), intent(in) :: question
		real(8), intent(in) :: defaulting, epsi
		print *, question
		read (*,*) query
		if (query < epsi) then
			query = defaulting
		endif
	end

end program
