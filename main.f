program navier
	implicit none
	real(8) :: Re = 100, tmax = 10, dt = 0.01
	real(8) :: h, beta, ideal
	real(8) :: t, div, delp
	integer :: i, j, iter, itmax = 300, n = 30, iflag = 0
	integer :: top, bottom, left, right, height
	real(8) :: epsi = 1e-6
	real(8), dimension(9) :: nn = [0, 5, 10, 20, 30, 40, 60, 100, 500]
	real(8), dimension(9) :: cc = [1.7, 1.78, 1.86, 1.92, 1.95, 1.96, 1.97, 1.98, 1.99]
	real(8) :: omega
	real(8), allocatable :: u(:,:), v(:,:), p(:,:), U_(:,:), V_(:,:), P_(:,:)
	real(8) :: fux, fuy, fvx, fvy, visu, visv
	real(8) :: max_speed = 0, current_speed = 0

	print *, 'Enter n (0 will default to 30): '
	read(*,*) n
	if (n == 0) then
		n = 30
	endif

	bottom = int((n+2)/4 + (n+2)/8);
	height = int((n+2)/4);
	top = bottom + height;
	left = bottom;
	right = top;

	omega = interp1(nn, cc, dble(n), 9)
	h = 1/real(n)
	beta = omega*h**2/(4*dt)
	allocate(u(n+2,n+2))
	u = 0
	v = u
	p = u

	print *, 'Enter Re (0 will default to 100): '
	read(*,*) Re
	if (Re < epsi) then
		Re = 100
	endif

	print *, 'Enter dt (0 will default to 0.01): '
	read(*,*) dt
	if (dt < epsi) then
		dt = 0.01
	endif

	!print *, h, Re*h**2.0/4.0, 2.0/Re
	ideal = min(h, Re*h**2.0/4.0, 2.0/Re)
	if (dt > ideal) then
		write(*,*) 'Warning! dt should be less than ', ideal
		read(*,*)
	endif

	t = 0.0
	do while (t <= tmax)
		i = 2
		do while (i <= n+1)
			j = 2
			do while (j <= n+1)
				fux=((u(i,j)+u(i+1,j))**2-(u(i-1,j)+u(i,j))**2)*0.25/h
				!if (isNan(fux)) then
					!print *, fux, i, j
					!stop 2
				!endif
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

		!if (t > 0.0) then
			!print *, u
			!print *, 'v=', v
			!stop
		!endif

		do iter = 1, itmax
			do j = 1, n+2
				u(1,j) = 0.1
				v(1,j) = -v(2,j)
				u(n+1,j) = 0.1
				v(n+2,j) = -v(n+1,j)
			enddo
			do i = 1, n+2
				v(i,n+1) = 0.0
				v(i,1) = 0.0
				! This is where we set the boundary condition
				u(i,n+2) = -u(i,n+1)
				u(i,1) = -u(i,2)
			enddo

			do j = bottom, top
				u(left,j)=0.0;
				v(left,j)=-v(left+1,j);
				u(right,j)=0.0;
				v(right+1,j)=-v(right,j);
			enddo
			do i = left, right
				v(i,top)=0.0;
				v(i,bottom)=0.0;
				u(i,top+1)=-u(i,top);
				u(i,bottom)=-u(i,bottom+1);
			enddo

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
		!print *, 'div = ', div
		if (iter >= itmax) then
			 print *, 'Warning! Time t= ', t, ' iter= ', iter,' div= ', div
		else
				write(*,*) 'Time t= ', t, ' iter= ', iter
		endif
		t = t + dt
	enddo

	do i = 1, n+2
		print *, 'column ', i
		do j = 1, n+2
			write(*,*) j, u(j, i), ' '
		enddo
		print *, ''
	enddo
	!print *, v

	allocate(U_(n,n))
	do i = 1, n
		do j = 1, n
			max_speed = max(sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2), max_speed)
		enddo
	enddo

	U_ = 0
	V_= U_
	P_ = U_
	print *, 'START VECTOR FIELD'
	do i = 1, n
		do j = 1, n
			current_speed = sqrt(((v(i+1,j)+v(i+1,j+1))/2)**2 + ((u(i,j+1)+u(i+1,j+1))/2)**2) / max_speed
			print *, real(i)/n, real(j)/n, 180/(355/113)*atan2((v(i+1,j)+v(i+1,j+1))/2, (u(i,j+1)+u(i+1,j+1))/2), current_speed
			P_(j,i) = p(i+1,j+1);
		enddo
	enddo
	! axis([0 n+1 0 n+1]);

contains

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

	real(8) function interp1(x, y, z, arsize)
		! Default: linear interpolation
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

	logical(4) function isNan(a)
		! Computes whether or not a value is of the IEEE NaN type
		implicit none
		real(8), intent(in) :: a
		isNan = a /= a
	end


end program
