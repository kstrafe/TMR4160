program navier
implicit none
real :: n = 500, Re = 100, tmax = 10, dt = 0.01
real :: itmax = 300, h, beta, ideal
real :: desired
real :: epsi = 1e-6
real, dimension(1:9) :: nn = [0, 5, 10, 20, 30, 40, 60, 100, 500]
real, dimension(1:9) :: cc = [1.7, 1.78, 1.86, 1.92, 1.95, 1.96, 1.97, 1.98, 1.99]
real :: omega
real, allocatable :: u(:,:), v(:,:), p(:,:)
omega = interp1(nn, cc, n, 9)
h = 1/n
beta = omega*h**2/(4*dt)
allocate(u(int(n+2),int(n+2)))
u = 0
v = u
p = u

ideal = min(h, Re*h**2/4, 2/Re)
if (dt > ideal ) then
write(*,*) 'Warning! dt should be less than ', ideal
read(*,*)
endif

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
