function f = rls2eval(KTEST,model)

%   RLS2EVAL 
%
%   Regularized least squares with two layers (predictions)
%   -----------------------------------------------------------------------
%   Copyright © 2010 Francesco Dinuzzo
% 
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   Please report comments, suggestions and bugs to:
%   francesco.dinuzzo@gmail.com
%
%   -----------------------------------------------------------------------
%   Inputs:
%   KTEST: Kernel matrices: cell array of (ellt x ell) matrices.
%   model: RLS2 model structure. 
%
%   -----------------------------------------------------------------------
%   Outputs:
%   f: Predictions using the test kernel matrix cell array stack KTEST. 
%   For classification, predictions are given by sign(f).
%
%   -----------------------------------------------------------------------
%   Example of usage:
%
%       f = RLS2EVAL(KTEST,model)
%   


if nargin < 2,
    error('MATLAB:rls2:NotEnoughInputs','RLS2EVAL requires at least two input arguments.');
end

if ~isfield(model, 'b') || ~isfield(model, 'c') || ~isfield(model, 'd') || ~isfield(model, 'S')
    error('MATLAB:rls2eval:MissingFields', 'Input arguments are not in the correct format.');
end

b = model.b;
c = model.c;
d = model.d;
S = model.S;

if  ~iscell(KTEST) || ~isreal(b) || ~isreal(c) || ~isreal(d) || ~isreal(S)
    error('MATLAB:rls2eval:ComplexCorD', 'Parameters must be real.');
end

%Number of basic kernels
n = length(KTEST);

[ellt ell] = size(cell2mat(KTEST(1)));

sb = size(b);
sc = size(c);
sd = size(d);
sS = size(S);

%Check sizes
if  ne(ell,sc(1)) || ne(n,sd(1)) || ne(n,sS(1)) || ne(sb(2),sc(2)) || ne(sc(2),sd(2)) || ne(sd(2),sS(2)) 
    error('MATLAB:rls2lineval:InputArg', 'Bad dimensions of input arguments')
end

%Number of outputs
m = sc(2);


%% Compute predictions

f = zeros(ellt,m);
for k=1:m
    B = find(ne(d(:,k),0));
    nker = length(B);
    R = zeros(ellt,ell);
    for i=1:nker
        R = R+S(B(i))*d(B(i))*cell2mat(KTEST(B(i)));
    end
    f(:,k) = R*c(:,k)+b(:,k);
end