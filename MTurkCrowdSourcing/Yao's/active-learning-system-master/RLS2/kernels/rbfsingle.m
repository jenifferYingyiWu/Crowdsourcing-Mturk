function K = rbfsingle(X1,X2)

%   The following kernels are computed: 
%   - Gaussian RBF kernels on each feature separately with 10 different 
%   amplitudes.
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
numsigma = 10;
sigmaspace = logspace(-4,4,numsigma);
m = numsigma*N;
K = cell(m,1);

%% Gaussian RBF kernels
for s2=1:N
    A = repmat(X1(:,s2).^2,1,ell2)+ repmat(X2(:,s2).^2',ell1,1)-2*X1(:,s2)*(X2(:,s2)');
    for s1 = 1:numsigma
        K((s2-1)*numsigma+s1) = {exp(-sigmaspace(s1)*A)};
    end
end

