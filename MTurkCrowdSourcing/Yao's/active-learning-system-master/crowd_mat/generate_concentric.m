function [X,Y]=generate_concentric(n,do_plot,randomseed,c1,r1,c2,r2)
rand('seed',randomseed);
randn('seed',randomseed);
if(rem(n,2)==1)
    n=n+1;
end
if(nargin<=3)
   c1 = [0 0]; 
   r1=1;
   c2=c1;
   r2=r1/2;
end
theta = rand(1,n/2)*2*pi;
X(1:n/2,1) = c1(1)+r1*cos(theta);
X(1:n/2,2) = c1(2)+r2*sin(theta);
Y(1:n/2)=1;
theta = rand(1,n/2)*2*pi;
X(n/2+(1:n/2),1) = c2(1)+r2*cos(theta);
X(n/2+(1:n/2),2) = c2(2)+r2*sin(theta);
Y(n/2+1:n)=-1;

if(do_plot)
    clf;plot(X(Y==1,1),X(Y==1,2),'ro')
    hold on
    plot(X(Y==-1,1),X(Y==-1,2),'g*')
    axis equal
end

end