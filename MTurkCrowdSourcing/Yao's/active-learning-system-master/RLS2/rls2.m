function model = rls2(K,Y,lambda,param)

%   RLS2 
%
%   Regularized least squares with two layers (training)
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
%   K: Kernel matrices: cell array of (ell x ell) matrices,
%   Y: Training outputs: (ell x m) matrix.
%   lambda: Regularization parameter.
%   param: RLS2 parameter structure:
%   - b: Intercept b. Default is 0.
%   - d0: Initial feature combination. Default is maximum alignment.
%   - S: Basis kernel scaling. Default is trace one normalization.
%   - maxIT: Maximum number of iteration. Default is 50000.
%   - verbose: Verbosity level. Either 0(off) or 1(verbose). Default is 0.
%
%   -----------------------------------------------------------------------
%   Outputs:
%   model: Output model. Structure containing the following fields:
%   - b: Intercept b
%   - c: Coefficients c
%   - d: Coefficients d
%   - S: Basis kernel scaling 
%   - iterations: Number of iterations
%   - objective: Values of the regularization functional at each iteration. 
%   - training_predictions: Training predictions. For binary classification, predictions 
%   are given by sign(training_predictions).
%   - df: Approximate degrees of freedom. 
%
%   -----------------------------------------------------------------------
%   Example of usage:
%
%       model = RLS2(K,Y,lambda,param)
%   


%% Handle mandatory input arguments
if nargin<3
    error('MATLAB:rls2:NotEnoughInputs','RLS2 requires at least three input arguments.');
end;

% Check for non-real inputs
if~isreal(cell2mat(K(1))) || ~isreal(Y) || ~isreal(lambda)
    error('MATLAB:rls2:ComplexCorD', 'X, Y and lambda must be real.');
end

sK = size(cell2mat(K(1)));
sy = size(Y);

% Check sizes
if  ne(sK(1),sK(2)) || ne(sK(1),sy(1)) 
    error('MATLAB:rls2lin:InputArg', 'Bad dimensions of input arguments')
end

% Number of training examples
ell = sK(1);

% Number of kernels
n = length(K);

% Number of outputs
m = sy(2);


%% Handle optional input arguments

if nargin<4
    defaultb =true;
    defaultd = true;
    defaultS = true;
    defaultmaxIT = true;
    defaultverbose = true;
else

    %Check param.b
    defaultb = check_param(param,'b',1,m);
    
    %Check param.d0
    defaultd = check_param(param,'d0',n,m);
    if (~defaultd)
        if (any(any(param.d0 < 0)) || any(any(sum(param.d0)> 1+sqrt(eps))) )
            warning('MATLAB:RLS2:NotFeasible','The suggested d0 is not feasible. Using default.');
            defaultd = true;
        end
    end
    
    %Check param.S
    defaultS = check_param(param,'S',n,m);
    if (~defaultS)
        if (any(param.S <= 0))
            warning('MATLAB:RLS2:NotFeasible','The suggested S is not feasible. Using default.');
            defaultS = true;
        end
    end
    
    %Check param.maxIT
    defaultmaxIT = check_param(param,'maxIT',1,1);
    if (~defaultmaxIT)
        if (any(param.maxIT < 1))
            warning('MATLAB:RLS2:NotFeasible','The suggested maxIT is not feasible. Using default.');
            defaultmaxIT = true;
        end
    end    
    
    %Check param.verbose
    defaultverbose = check_param(param,'verbose',1,1);
    if (~defaultverbose)
        if (ne(param.verbose,0) && ne(param.verbose,1))
            warning('MATLAB:RLS2:NotFeasible','The suggested verbose is not feasible. Using default.');
            defaultverbose = true;
        end
    end
end

%% Initialization

%Default initialization of b
if (defaultb)
    param.b = zeros(1,m);
end

%Output normalization
Y = Y-ones(ell,1)*param.b;

%Default initialization of S
if (defaultS)
    param.S = zeros(n,m);
    for i=1:n
        param.S(i,:) = ones(1,m)/(trace(cell2mat(K(i)))+sqrt(eps));
    end
end

%Default initialization of d
if (defaultd)
    g = zeros(n,m);
    for i=1:n
        for j=1:m
        R = cell2mat(K(i));
        g(i,j) = param.S(i,j)*Y(:,j)'*R*Y(:,j);
        end
    end
    [mm,j] = max(g);
    param.d0 = sparse(j,1:m,ones(1,m),n,m);
end

%Default initialization of maxIT
if(defaultmaxIT)
    param.maxIT = 50000;
end

%Default initialization of verbose
if(defaultverbose)
    param.verbose = 0;
end

%Main loop stopping criterion tolerance (squared relative residual)
tol = 1e-4;

%SMO stopping criterion tolerance
tolSMO = 1000*n*sqrt(eps);

%Maximum SMO iterations
maxSMOIT = 20000;

%Maximum iterations
maxIT = param.maxIT;

%Verbosity level
verbose = param.verbose;

%% RLS2 Optimization
for k=1:m
    if (m > 1)
        disp(sprintf('---------------\nProcessing output number %d',k));
    end
    b = param.b(:,k);
    d = param.d0(:,k);
    S = param.S(:,k);

%% Iteration 1
    nit = 1;

    %Indices of selected kernels
    B = find(ne(d,0));
    
    %Objective functional values
    J = zeros(1,maxIT);

    nker = length(B);
    r = Y(:,k);
    res = norm(r)^2;
    J(1) = res/2;
    c = sparse(ell,1);
    if (verbose)
        s = sprintf('---------------\nIteration: %d \nObjective = %d \nRelative residual = %d \nNumber of selected kernels = %d',nit-1,J(nit),full(sqrt(res/(2*J(1)))),length(B));
    else
        s = sprintf('Iteration: %d',nit-1);
    end
    disp(s);

%% Last iteration (lambda = +inf)
    if (eq(lambda,inf))
        training_predictions = sparse(ell,1);
        iterations = 1;
        df = 0;
    else

%% Main loop (lambda < +inf)
        while (res > tol*2*J(1) && nit < maxIT)
            nit = nit+1;

            %Build kernel matrix
            R = zeros(ell,ell);
            for i=1:nker
                R = R+S(B(i))*d(B(i))*cell2mat(K(B(i)));
            end

            %Conjugate gradient
            dd = r;
            while(res > tol*2*J(1))
                qq = R*dd+lambda*dd;
                alphak = res/(qq'*dd);
                c = c+alphak*dd;
                r = r-alphak*qq;
                tmp = sum(r.^2);
                betak = tmp/res;
                res = tmp;
                dd = r +betak*dd;
            end

            %Objective functional
            J(nit) = lambda*Y(:,k)'*c/2;

            V = zeros(ell,m);
            for i=1:n
                V(:,i) = S(i)*cell2mat(K(i))*c;
            end

            %SMO subproblem
            w = V(:,B)*d(B)+lambda*c/2-Y(:,k);
            g = V'*w;

            %Maximal violating pair selection
            [mm i] = min(g);
            [MM jj] = max(g(B));
            j = B(jj);

            t = MM-mm;
            kk = 1;
            while (t > tolSMO && kk < maxSMOIT)
                kk = kk+1;
                if (eq(d(i),0))
                    B = union(B,i);
                    nker = length(B);
                end
                kkk = 1;
                VB = V(:,B);

                v = V(:,i)-V(:,j);
                while(kkk < 10000 && nker > 1)
                    kkk = kkk +1;
                    gamma = t/norm(v)^2;
                    p = min(d(j),gamma);
                    d(i) = d(i) + p;
                    if(eq(p,gamma))
                        d(j) = d(j) - p;
                    else
                        d(j) = 0;
                        B = setdiff(B,j);
                        nker = length(B);
                        VB(:,jj) = [];
                    end
                    w =w+p*v;
                    gB = VB'*w;
                    [mm ii] = min(gB);
                    [MM jj] = max(gB);
                    v = VB(:,ii)-VB(:,jj);
                    i = B(ii);
                    j = B(jj);
                    t = MM-mm;
                    if (t <= tolSMO)
                        break;
                    end
                end

                w = V(:,B)*d(B)+lambda*c/2-Y(:,k);
                g = V'*w;
                %Maximal violating pair selection
                [mm i] = min(g);
                t = MM-mm;
            end
            %End SMO subproblem
            if (eq(kk,maxSMOIT))
                disp('SMO reached the maximum number of iteration');
            end

            %Predictions on training inputs
            training_predictions = V(:,B)*d(B);

            %Residual
            r = Y(:,k)-training_predictions-c*lambda;

            %Residual sum of squares
            res = sum(r.^2);

            %Output diagnostics
            if (verbose)
                s = sprintf('---------------\nIteration: %d \nObjective = %d \nRelative residual = %d \nNumber of selected kernel = %d',nit-1,J(nit),full(sqrt(res/(2*J(1)))),length(B));
            else
                s = sprintf('Iteration: %d',nit-1);
            end
            disp(s);
        end
%% Last iteration (lambda < +inf)
        iterations = nit-1;
        J = J(1:nit)';

        %Build kernel matrix
        R = zeros(ell,ell);
        for i=1:nker
            R = R+S(B(i))*d(B(i))*cell2mat(K(B(i)));
        end

        %Predictions on training inputs
        training_predictions = R*c +b;

        %Return approximate degrees of freedom
        df = ell-lambda*trace(inv(R+lambda*eye(ell,ell)));
    end
%% Output results
    model.b(:,k) = b;
    model.c(:,k) = c;
    model.d(:,k) = d;
    model.S(:,k) = S;
    model.training_predictions(:,k) = training_predictions;
    model.iterations(:,k) = iterations;
    model.objective(k) = {J};
    model.df(:,k) = df;
end
%% Display final messages
if (eq(iterations,maxIT))
    disp(sprintf('---------------\nMaximum number of iterations reached'));
end
disp(sprintf('---------------\nOptimization terminated'));





%% Check input parameter sub-function
function default = check_param(structure,name,n,m)
default = false;
if(isfield(structure, name))
    x = structure.(name);
    if(~isempty(x))
        if(isreal(x))
            s=size(x);
            if(ne(s(1),n) || ne(s(2),m))
                warning('MATLAB:RLS2LIN:WrongSize', 'Wrong size for %s. Using default.',name);
                default = true;
            end
        else
            warning('MATLAB:RLS2LIN:ComplexCorD', '%s must be real. Using default.',name)
            default = true;
        end
    else
        default = true;
    end
else
    default = true;
end;