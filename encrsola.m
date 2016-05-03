% SOLA - MATLAB

clear all
close all
clc
n=30;
epsi=1e-6;
nn=[0   5	10   20   30   40   60   100  500];
oo=[1.7 1.78 1.86 1.92 1.95 1.96 1.97 1.98 1.99];
omega=interp1(nn,oo,n);  % Interpolating a reasonable value
Re=3000;
tmax=10;
dt=0.01;
itmax=300;
h=1/n;
beta=omega*h^2/(4*dt);
u=zeros(n+2,n+2);v=u;p=u;

if dt>min([h,Re*h^2/4,2/Re])
	disp(['Warning! dt should be less than ', num2str(min([h,Re*h^2/4,2/Re]))])
	pause
end

bottom = int64((n+2)/4 + (n+2)/8);
height = int64((n+2)/4);
top = bottom + height;
left = bottom;
right = top;

for t=0:dt:tmax  % Main loop
	for i=2:n+1  % CalVel, calculation of velocities
		for j=2:n+1
			fux=((u(i,j)+u(i+1,j))^2-(u(i-1,j)+u(i,j))^2)*0.25/h;
			fuy=((v(i,j)+v(i+1,j))*(u(i,j)+u(i,j+1))-(v(i,j-1)+v(i+1,j-1))*(u(i,j-1)+u(i,j)))*0.25/h;
			fvx=((u(i,j)+u(i,j+1))*(v(i,j)+v(i+1,j))-(u(i-1,j)+u(i-1,j+1))*(v(i-1,j)+v(i,j)))*0.25/h;
			fvy=((v(i,j)+v(i,j+1))^2-(v(i,j-1)+v(i,j))^2)*0.25/h;
			visu=(u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4.0*u(i,j))/(Re*h^2);
			visv=(v(i+1,j)+v(i-1,j)+v(i,j+1)+v(i,j-1)-4.0*v(i,j))/(Re*h^2);
			u(i,j)=u(i,j)+dt*((p(i,j)-p(i+1,j))/h-fux-fuy+visu);
			v(i,j)=v(i,j)+dt*((p(i,j)-p(i,j+1))/h-fvx-fvy+visv);
		end
	end
	for iter=1:itmax  % BcVel, Boundary conditions for the velocities
		for j=1:n+2
			u(1,j)=0.0+0.1;
			v(1,j)=-v(2,j);
			u(n+1,j)=0.0+0.1;
			v(n+2,j)=-v(n+1,j);
		end
		for i=1:n+2
			v(i,n+1)=0.0;
			v(i,1)=0.0;
			u(i,n+2)=-u(i,n+1);
			u(i,1)=-u(i,2);
		end

		for j=bottom:top
			u(left,j)=0.0;
			v(left,j)=-v(left+1,j);
			u(right,j)=0.0;
			v(right+1,j)=-v(right,j);
		end
		for i=left:right
			v(i,top)=0.0;
			v(i,bottom)=0.0;
			u(i,top+1)=-u(i,top);
			u(i,bottom)=-u(i,bottom+1);
		end

		iflag=0;  % Piter, Pressure iterations
		for j=2:n+1
			for i=2:n+1
				div=(u(i,j)-u(i-1,j))/h+(v(i,j)-v(i,j-1))/h;
				if (abs(div)>=epsi)
					iflag=1;
				end
				delp=-beta*div;
				p(i,j)  =p(i,j)  +delp;
				u(i,j)  =u(i,j)  +delp*dt/h;
				u(i-1,j)=u(i-1,j)-delp*dt/h;
				v(i,j)  =v(i,j)  +delp*dt/h;
				v(i,j-1)=v(i,j-1)-delp*dt/h;
			end
		end
		if(iflag==0)break,end
	end
	if iter>=itmax
	   disp(['# Warning! Time t= ',num2str(t),' iter= ',int2str(iter),' div= ',num2str(div)])
	else
		disp(['# Time t= ',num2str(t),' iter= ',int2str(iter)])
	end

end

% Graphic display:

U=zeros(n);
V=U;
P=U;
for i=1:n
	for j=1:n
		U(j,i)=(u(i,j+1)+u(i+1,j+1))/2;
		V(j,i)=(v(i+1,j)+v(i+1,j+1))/2;
		P(j,i)=p(i+1,j+1);
	end
end
figure(1)
quiver(U,V);
axis([0 n+1 0 n+1]);
title(['Velcity vectors, Re =',num2str(Re)])
figure(2)
contourf(P,30)
title('Pressure')
grid on

figure(3)
psi=zeros(n+1);
for i=2:n+1
	psi(i,1)=psi(i-1,1)-v(i,1)*h;
end
for i=1:n+1
	for j=2:n+1
		psi(i,j)=psi(i,j-1)+u(i,j)*h;
	end
end
psi=-psi';
[C,H]=contour(psi);
clabel(C)
title(['Streamfunction \psi_{max}=',num2str(max(max(abs(psi))))])

dlmwrite('correct/velocities_u', transpose(U));
dlmwrite('correct/velocities_v', transpose(V));
