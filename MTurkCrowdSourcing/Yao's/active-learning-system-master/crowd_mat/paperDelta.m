function Delta = paperDelta(itemIndex, nCols, err_minus, err_plus)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
n = itemIndex;
d = nCols;

delta = 0.05;
S = (2*n)^d;
beta = sqrt((4/n)*log(8*(n*n+n)*S*S/delta));
Delta = beta*beta + beta*(sqrt(err_minus)+sqrt(err_plus));

end

