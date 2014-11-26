function A = areaUnderCurve(X, Y)

ind = find(~isnan(Y));
X = X(ind);
Y = Y(ind);

if isempty(X)
    A = 0;
elseif isscalar(X)
    A = Y;
else
    A = trapz(X, Y);
end

end

