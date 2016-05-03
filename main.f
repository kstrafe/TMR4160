program navier
	! Fjern automatiske indeks variabler
	implicit none

	! Sett reynolds tall, tids-endingen, og tids-steppet
	! dt må settes selv om den settes senere, ellers får vi en intern
	! kompilator feil
	real(8) :: Re, dt, tmax

	! Hvor stor den horisontale strømmen gjennom kanalen er
	real(8) :: flow

	! Variabler til stabilitets beregning
	real(8) :: h, beta, ideal, omega
	real(8), dimension(9) :: nn = [0, 5, 10, 20, 30, 40, 60, 100, 500]
	real(8), dimension(9) :: cc = [1.7, 1.78, 1.86, 1.92, 1.95, 1.96, 1.97, 1.98, 1.99]

	! Iterator hjelpere til time steppet
	real(8) :: t, div, delp

	! Iteratorers
	integer :: i, j, iter, b

	! Maks verdi på iterasjonen og feil endings flagget
	integer :: itmax = 300, iflag = 0

	! Grid størrelse
	integer :: n

	! Indeksene for boksen som står i strømmen
	integer :: top, bottom, left, right

	! Maskin epsilon
	real(8), parameter :: epsi = 1e-6

	! Hastighet, trykk, og strømningsfelt
	real(8), allocatable :: u(:,:), v(:,:), p(:,:), psi(:,:)

	! Midlertidige verdier for løsningen av Navier-Stokes
	real(8) :: fux, fuy, fvx, fvy, visu, visv

	! Om vi skal spørre igjen
	logical(4) :: keep_looping = .true.

	! Dude
	integer :: blocked
	integer, allocatable :: block_x_start(:), block_y_start(:), block_x_stop(:), block_y_stop(:)

	do while (keep_looping)
		flow = query('# Enter flow (0 will default to 0.1): ', dble(0.1), epsi)

		! Få grid størrelsen
		n = int(query('# Enter n (0 will default to 30): ', dble(30), epsi))

		! Alloker minne til strømfunksjonens verdier
		allocate(psi(n+1,n+1))
		psi = 0

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
			if (.not. queryBool('# Ønsker du å fortsette med disse verdier? (y/Y for ja, ellers nei): ')) then
				deallocate(psi)
				deallocate(u)
				deallocate(v)
				deallocate(p)
				cycle
			endif
		endif
		keep_looping = .false.
	enddo

	blocked = int(query('# Enter the amount of blockers: ', dble(0), epsi))
	allocate(block_x_start(blocked))
	allocate(block_y_start(blocked))
	allocate(block_x_stop(blocked))
	allocate(block_y_stop(blocked))

	do i = 1, blocked
		block_x_start(i) = int(query('# Enter the starting x coordinate of the block: ', dble(1), epsi))
		block_x_stop(i) = int(query('# Enter the stopping x coordinate of the block: ', dble(1), epsi))
		block_y_start(i) = int(query('# Enter the starting y coordinate of the block: ', dble(1), epsi))
		block_y_stop(i) = int(query('# Enter the stopping y coordinate of the block: ', dble(1), epsi))
		if (max(block_x_start(i), block_x_stop(i), block_y_start(i), block_y_stop(i), n) /= n) then
			print *, '# Error: boundary condition outside of the grid size (> n). Aborting.'
			stop 2
		endif
		if (min(block_x_start(i), block_x_stop(i), block_y_start(i), block_y_stop(i), 0) /= 0) then
			print *, '# Error: boundary condition outside of the grid size (negative). Aborting.'
			stop 2
		endif
	enddo


	print *, '# Re', Re
	print *, '# dt', dt
	print *, '# tmax', tmax
	print *, '# n', n
	print *, '# ideal dt', ideal

	t = 0.0
	do while (t <= tmax)
		! --------------------------------------------------------------------
		! Start Navier-Stokes tidssteg
		! --------------------------------------------------------------------
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
				u(1,j) = flow
				v(1,j) = -v(2,j)
				u(n+1,j) = flow
				v(n+2,j) = -v(n+1,j)
			enddo
			! Topp og bunn rand
			do i = 1, n+2
				v(i,n+1) = 0.0
				v(i,1) = 0.0
				u(i,n+2) = -u(i,n+1)
				u(i,1) = -u(i,2)
			enddo

			do b = 1, blocked
				left = block_x_start(b)
				right = block_x_stop(b)
				top = block_y_stop(b)
				bottom = block_y_start(b)

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

		! --------------------------------------------------------------------
		! Slutt Navier-Stokes tidssteg
		! --------------------------------------------------------------------

		! Print resultatene til stdout slik de kan bli gjort om til bilder
		call printSpeed(u, v, n, t)
		call printPressure(p, n, t)
		call printStream(u, v, psi, n, t)

	enddo

	call printSpeedInMatrix(u, v, n, t)

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

	!   --------------------------------------------------------------------
	!     Function                 query                            No.: 4
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Spørre stdin om et tall, og defaulte dersom tallet er mindre enn
	!   en viss verdi
	!   Metode :
	!   Skrive spørsmålet ut og reade fra stdin, deretter sjekke om
	!   tallet er gyldig
	!
	!   Kall sekvens .......................................................
	!
	!    query(question, defaulting, epsi)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   query       O    R(8)    Double verdien som blir lest inn
	!   question    I    C(*)    Spørsmålet som blir skrive ut
	!   defaulting  I    R(8)    Verdien som ellers blir brukt om inputt er ugyldig
	!   epsi        I    R(8)    Verdien som sammenlignes med inputt
	!
	!     I N T E R N E   V A R I A B L E :
	!       Ingen
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.28 / 1.0
	!
	! **********************************************************************
	!
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

	!   --------------------------------------------------------------------
	!     Function                 queryBool                        No.: 5
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Spørre via stdin om ja eller nei ved y/n
	!   Metode :
	!   Sjekke om inputt er y eller Y, ellers blir det nei
	!
	!   Kall sekvens .......................................................
	!
	!    queryBool(question)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   query       O    L(4)    Boolske svaret til spørsmålet
	!   question    I    C(*)    Spørsmålet som blir skrive ut
	!
	!     I N T E R N E   V A R I A B L E :
	!       Ingen
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.28 / 1.0
	!
	! **********************************************************************
	!

	logical(4) function queryBool(question)
		implicit none
		character(len=*), intent(in) :: question
		character(1) :: answer
		print *, question
		read (*,*) answer
		queryBool = answer == 'y' .or. answer == 'Y'
	end

	!   --------------------------------------------------------------------
	!     Subroutine                 printSpeed                     No.: 1
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Printe hastighetsfeltet til stdout
	!   Metode :
	!   Finne maksimal of minimal hastighet, vinkel, og printe hastighetene
	!   med verdi mellom 0 og 1.
	!
	!   Kall sekvens .......................................................
	!
	!    printSpeed(u, v, n)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   u           I    R(:,:)   Hastighet i x-retning
	!   v           I    R(:,:)   Hastighet i y-retning
	!   n           I    I        Størrelsen på u og v (kantene)
	!   t           I    R(8)     Tiden nå
	!
	!     I N T E R N E   V A R I A B L E :
	!       min_speed      Holder rede på den minste hastigheten
	!       max_speed      Holder rede på den største hastigheten
	!       angle          Vinkelen til det nåværende punktet
	!       current_speed  Hastigheten til det nåværende punktet
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.28 / 1.0
	!
	! **********************************************************************
	!
	subroutine printSpeed(u, v, n, t)
		! Beregn minste hastighet for denne framen
		implicit none
		real(8), allocatable, intent(in) :: u(:,:), v(:,:)
		integer, intent(in) :: n
		real(8), intent(in) :: t
		real(8) :: min_speed, max_speed, angle, current_speed

		min_speed = sqrt(((v(2,1)+v(2,2))/2)**2 + ((u(1,2)+u(2,2))/2)**2)
		do i = 1, n
			do j = 1, n
				min_speed = min(sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2), min_speed)
			enddo
		enddo
		! Beregn største hastighet for denne framen
		max_speed = sqrt(((v(2,1)+v(2,2))/2)**2 + ((u(1,2)+u(2,2))/2)**2)-min_speed
		do i = 1, n
			do j = 1, n
				max_speed = max(sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2)-min_speed, max_speed)
			enddo
		enddo

		! Print ut vektor feltet
		print *, '# BEGIN VECTOR FIELD'
		print *, '# MAX VALUE', max_speed
		print *, '# MIN VALUE', min_speed
		print *, '# TIME', t
		do i = 1, n
			do j = 1, n
				current_speed = sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2) / max_speed
				angle = atan2((v(i+1,j)+v(i+1,j+1))/2, (u(i,j+1)+u(i+1,j+1))/2)
				print *, real(i-1)/(n-1), real(j-1)/(n-1), angle, current_speed
				if (isNan(angle)) then
					stop 2
				endif
			enddo
		enddo
		print *, '# END VECTOR FIELD'

	end

	!   --------------------------------------------------------------------
	!     Subroutine                 printPressure                  No.: 2
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Printe trykkfeltet til stdout
	!   Metode :
	!   Finne maksimalt of minimalt trykk, verdi, og printe trykket
	!   med verdi mellom 0 og 1.
	!
	!   Kall sekvens .......................................................
	!
	!    printPressure(p, n)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   p           I    R(:,:)   Trykk for hver posisjon
	!   n           I    I        Størrelsen på p (kantene)
	!   t           I    R(8)     Tiden nå
	!
	!     I N T E R N E   V A R I A B L E :
	!       max_pressure      Holder rede på det største trykket
	!       min_pressure      Holder rede på det minste trykket
	!       current_pressure  Trykket til det nåværende punktet
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.28 / 1.0
	!
	! **********************************************************************
	!
	subroutine printPressure(p, n, t)
		implicit none
		! Beregn det minste trykket for denne framen
		real(8), allocatable, intent(in) :: p(:,:)
		integer, intent(in) :: n
		real(8), intent(in) :: t
		real(8) :: max_pressure, min_pressure, current_pressure

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
		print *, '# TIME', t
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

	end

	!   --------------------------------------------------------------------
	!     Subroutine                 printStream                    No.: 3
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Printe strømfunksjonen til stdout
	!   Metode :
	!   Finne maksimal og minimal strøm, og normaliser strømingen i punktet.
	!   Print denne verdien til stdout
	!
	!   Kall sekvens .......................................................
	!
	!    printStream(u, v, psi, n)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   u           I    R(:,:)   Hastighet i x-retning
	!   v           I    R(:,:)   Hastighet i y-retning
	!   psi         I    R(:,:)   Strømfeltet
	!   n           I    I        Størrelsen på p (kantene)
	!   t           I    R(8)     Tiden nå
	!
	!     I N T E R N E   V A R I A B L E :
	!       max_streamline      Holder rede på den største strøm
	!       min_streamline      Holder rede på den minste strøm
	!       current_stream      Strøm til det nåværende punktet
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.04.28 / 1.0
	!
	! **********************************************************************
	!
	subroutine printStream(u, v, psi, n, t)
		implicit none
		! Beregn strømningsfunksjonen
		real(8), allocatable, intent(in) :: u(:,:), v(:,:)
		real(8), allocatable :: psi(:,:)
		real(8), intent(in) :: t
		integer, intent(in) :: n
		real(8) :: max_streamline, min_streamline, current_stream

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
		print *, '# TIME', t
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

	end

	!   --------------------------------------------------------------------
	!     Subroutine                 printSpeedInMatrix             No.: 4
	!   --------------------------------------------------------------------
	!
	!   Hensikt :
	!   Printe ut hastighetsfeltet i matrise form, slik den er enkel å sammen-
	!   ligne med matlab
	!   Metode :
	!   Gå gjennom matrisen og print hvert element for seg. Hver rad separerer
	!   en linje. Hver kolonne er komma separert
	!
	!   Kall sekvens .......................................................
	!
	!    printSpeedInMatrix(u, v, n, t)
	!
	!   Parametre:
	!   Navn        I/O  Type     Innhold/Beskrivelse
	!   .................................................................
	!   u           I    R(:,:)   Hastighet i x-retning
	!   v           I    R(:,:)   Hastighet i y-retning
	!   n           I    I        Størrelsen på u (kantene)
	!   t           I    R(8)     Tiden nå (dette tidspunktet)
	!
	!     I N T E R N E   V A R I A B L E :
	!       formatter          Brukes til å formattere utputt
	!
	!   Programmert av: Kevin Robert Stravers
	!   Date/Version  : 2016.05.03 / 1.0
	!
	! **********************************************************************
	!
	subroutine printSpeedInMatrix(u, v, n, t)
		! Print ut verdiene for hastighetsmatrisene
		implicit none
		real(8), allocatable, intent(in) :: u(:,:), v(:,:)
		integer, intent(in) :: n
		real(8), intent(in) :: t
		character(len=*), parameter :: formatter = "(F20.12)"

		! Print ut vektor feltet
		print *, '# BEGIN VELOCITY U'
		print *, '# TIME', t
		do i = 1, n
			write(*,formatter,advance='no') (u(i,2)+u(i+1,2))/2
			do j = 2, n
				write(*,"(A)",advance='no') ','
				write(*,formatter,advance='no') (u(i,j+1)+u(i+1,j+1))/2
			enddo
			print *,
		enddo
		print *, '# END VELOCITY U'

		print *, '# BEGIN VELOCITY V'
		print *, '# TIME', t
		do i = 1, n
			write(*,formatter,advance='no') (v(i+1,1)+v(i+1,2))/2
			do j = 2, n
				write(*,"(A)",advance='no') ','
				write(*,formatter,advance='no') (v(i+1,j)+v(i+1,j+1))/2
			enddo
			print *,
		enddo
		print *, '# END VELOCITY V'

	end

end program
