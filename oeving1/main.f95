	program prog
	implicit none
	integer :: i, ierror
	real :: x
	real, dimension(2) :: largest, current
	real :: f

	! Part 2: 1)
	real :: step
	real, dimension(3) :: abn
	character, dimension(3) :: names = (/ 'A','B','N' /)

	do while (.true.)
		do i = 1, 3
			write(*,'(A)',advance='no') '# ' // names(i) // ' = '
			read(*,*,iostat=ierror) abn(i)
		end do
		if (abn(1) >= abn(2)) then
			write(*,*) '# The ranges are invalid, please retry.'
			cycle
		else if (abn(3) <= 1) then
			write(*,*) '# There must be more than one step.'
			cycle
		end if
		exit
	end do
	! End 2:1

	! Part 2: 2)
	step = (abn(2) - abn(1)) / (abn(3)-1)
	x = abn(1)
	largest = (/ abn(1), f(abn(1)) /)

	do i = 1, int(abn(3))
		current = (/ x, f(x) /)
		if (current(2) > largest(2)) largest = current
		write(*,*) current
		x = x + step
	end do

	! Part 2: 4)
	write(*,*) '# Largest: ', largest
	! End 2:2

	end program prog


	! Part 2: 2)
	real function f(x)
		implicit none
		real, intent(in) :: x
		real, parameter :: pi = 4.0*atan(1.0)
		f = x**2*sin(pi*x)
	end
	! End 2:2
