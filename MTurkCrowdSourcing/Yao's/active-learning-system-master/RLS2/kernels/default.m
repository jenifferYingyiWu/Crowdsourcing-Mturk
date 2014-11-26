function K = default(X1,X2)

%   Example of customized kernel function for RLS2. 
%   The function must return a cell array of kernel matrices
%   of the same size obtained by computing all the cross kernels 
%   between the two sets X1 and X2 of input patterns.
%
%   The following kernels are computed: 
%   - Polynomial kernels of degree 1, 2, 3 on all the the features 
%   and on each single feature separately.
%   - Gaussian RBF kernels on all the features and on each 
%   single feature separately with 10 different amplitudes.
%
% Copyright (c) 2010 Francesco Dinuzzo
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%  Please report comments, suggestions and bugs to:
%  francesco.dinuzzo@gmail.com
%

[ell1 N] = size(X1);
ell2 = size(X2,1);

degree = 3;
numsigma = 10;
sigmaspace = logspace(-3,3,numsigma);

m = (numsigma+degree)*(N+1);

K = cell(m,1);
k = 0;

%% Polynomial kernels
for s1=1:degree
    k = k+1;
    K(k) = {(X1*(X2')+1).^s1};
    for s2=1:N
        k = k+1;
        K(k) = {(X1(:,s2)*(X2(:,s2)')+1).^s1};
    end
end

%% Gaussian RBF kernels
S1 = sum(X1.^2,2);
S2 = sum(X2.^2,2);
A = repmat(S1,1,ell2)+ repmat(S2',ell1,1)-2*X1*(X2');
for s1 = 1:numsigma
    k = k+1;
    K(k) = {exp(-sigmaspace(s1)*A)};
end

for s2=1:N
    A = repmat(X1(:,s2).^2,1,ell2)+ repmat(X2(:,s2).^2',ell1,1)-2*X1(:,s2)*(X2(:,s2)');
    for s1 = 1:numsigma
        k = k+1;
        K(k) = {exp(-sigmaspace(s1)*A)};
    end
end

