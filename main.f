program navier
	implicit none
	real :: Re = 100, tmax = 10, dt = 0.01
	real :: h, beta, ideal
	real :: desired, t, div, delp
	integer :: i, j, iter, itmax = 300, n = 30, iflag = 0
	real :: epsi = 1e-6
	real, dimension(1:9) :: nn = [0, 5, 10, 20, 30, 40, 60, 100, 500]
	real, dimension(1:9) :: cc = [1.7, 1.78, 1.86, 1.92, 1.95, 1.96, 1.97, 1.98, 1.99]
	real :: omega
	real, allocatable :: u(:,:), v(:,:), p(:,:)
	real :: fux, fuy, fvx, fvy, visu, visv
	omega = interp1(nn, cc, real(n), 9)
	h = 1/real(n)
	beta = omega*h**2/(4*dt)
	allocate(u(n+2,n+2))
	u = 0
	v = u
	p = u

	write(*,*) h, Re*h**2/4, 2/Re
	ideal = min(h, Re*h**2/4, 2/Re)
	if (dt > ideal ) then
	write(*,*) 'Warning! dt should be less than ', ideal
	read(*,*)
	endif

	t = 0.0
	do while (t < tmax)
		i = 2
		do while (i < n+1)
			i = i + 1
			j = 2
			do while (j < n+1)
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
		enddo
		do iter = 1, itmax
			do j = 1, n+2
				v(1,j) = 0.0
				v(1,j) = -v(2,j)
				u(n+1,j) = 0.0
				v(n+2,j) = -v(n+1,j)
			enddo
			do i = 1, n+2
				v(i,n+1) = 0.0
				v(i,1) = 0.0
				u(i,n+2) = -u(i,n+1)+2.0
				u(i,1) = -u(i,2)
			enddo
			iflag = 0

			do j = 2, n+1
				do i = 2, n+1
					div = (u(i,j)-u(i-1,j))/h+(v(i,j)-v(i,j)-1)/h
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
			 write(*,*) 'Warning! Time t= ', t, ' iter= ', iter,' div= ', div
		else
				write(*,*) 'Time t= ', t, ' iter= ', iter
		endif
		t = t + dt
	enddo

contains

	integer function closestIndex(array, arsize, desired)
		! Let x be a monotonically increasing array
		! Val is the value to find the closest index to
		implicit none
		real, dimension(:), intent(in) :: array
		integer, intent(in) :: arsize
		integer :: i
		real, intent(in) :: desired
		real :: min_distance, distance

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
		real, dimension(:), intent(in) :: array
		integer, intent(in) :: arsize
		integer, intent(in) :: closest
		real, intent(in) :: desired
		real :: next_closest
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

	real function interp1(x, y, z, arsize)
		! Default: linear interpolation
		implicit none
		real, dimension(:), intent(in) :: x, y
		real, intent(in) :: z
		real xdiff, ydiff, zdiff
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


end program
