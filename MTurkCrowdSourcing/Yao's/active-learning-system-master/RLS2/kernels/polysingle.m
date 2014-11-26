function K = polysingle(X1,X2)

%   The following kernels are computed: 
%   - Polynomial kernels of degree 1, 2, 3 on each feature separately.
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

degree = 3;
[ell1 N] = size(X1);
m = degree*N;
K = cell(m,1);

%% Polynomial kernels
for s1=1:degree
    for s2=1:N
        K((s2-1)*degree+s1) = {(X1(:,s2)*(X2(:,s2)')+1).^s1};
    end
end