function [X,Y,Z]=generate_data_simple(n,d,sep,do_plot,randomseed)
% n is the total number of data points (n/2 with label 0 and n/2 with label
% 1). d is the dimension. sep is the distance between the center of the two
% guassians. 
% X is the n data points and Y is the labels. You can ignore Z.


rand('seed',randomseed);
randn('seed',randomseed);
if rem(n,2)==1
   n=n+1; 
end
mu1=-sep/2;
mu2=sep/2;
X = [mu1+randn(n/2,d); mu2+randn(n/2,d)];
W = ones(1,d);
Z = 1./(1+exp(W*X'));
p = rand(1,n);

Y=zeros(n,1);
Y(p<Z)=1;
%Y = 2*Y-1;

if(do_plot)
    clf;
    if d==2
        plot(X(Y==1,1),X(Y==1,2),'ro')
        hold on
        plot(X(Y==0,1),X(Y==0,2),'g*')
    else if d==1
            plot(X(Y==1,1),X(Y==1,1),'ro')
            hold on
            plot(X(Y==0,1),X(Y==0,1),'g*')
        end
    end
    axis equal
end
end