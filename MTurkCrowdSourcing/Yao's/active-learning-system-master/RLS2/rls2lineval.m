function f = rls2lineval(XTEST,XTRAIN,model)

%   RLS2LINEVAL 
%
%   Linear regularized least squares with two layers (predictions)
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
%   XTEST: Test inputs: (ellt x n) matrix .
%   XTRAIN: Training inputs: (ell x n) matrix .
%   model: RLS2LIN model structure. 
%
%   -----------------------------------------------------------------------
%   Outputs:
%   f: Predictions on test inputs XTEST. For binary classification, predictions 
%   are given by sign(f).
%
%   -----------------------------------------------------------------------
%   Example of usage:
%
%       f = RLS2LINEVAL(XTEST,XTRAIN,model)
%   


%% Check input arguments

if nargin < 3,
    error('MATLAB:rls2lineval:NotEnoughInputs','RLS2LINEVAL requires at least three input arguments.');
end

if ~isfield(model, 'b') || ~isfield(model, 'c') || ~isfield(model, 'd') || ~isfield(model, 'S')
    error('MATLAB:rls2lineval:MissingFields', 'Input arguments are not in the correct format.');
end

b = model.b;
c = model.c;
d = model.d;
S = model.S;

if  ~isreal(XTEST) || ~isreal(XTRAIN) || ~isreal(b) || ~isreal(c) || ~isreal(d) || ~isreal(S)
    error('MATLAB:rls2lineval:ComplexCorD', 'Parameters must be real.');
end

%Number of attributes
[ell n] = size(XTRAIN);
[ellt nt] = size(XTEST);

sb = size(b);
sc = size(c);
sd = size(d);
sS = size(S);

%Check sizes
if  ne(nt,n) || ne(ell,sc(1)) || ne(n,sd(1)) || ne(n,sS(1)) || ne(sb(2),sc(2)) || ne(sc(2),sd(2)) || ne(sd(2),sS(2)) 
    error('MATLAB:rls2lineval:InputArg', 'Bad dimensions of input arguments')
end

m = sc(2);

%% Compute predictions
B = ne(d,0);
Z = XTRAIN'*c;
w = sparse(n,m);
w(B) = d(B).*Z(B).*S(B);
f = XTEST*w+ones(ellt,1)*b;