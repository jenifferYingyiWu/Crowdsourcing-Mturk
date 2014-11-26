function q = infdiv( x , y )

if ~isvector(x) || ~isvector(y)
    error('invalid input');
end

ind = find(y~=0);

q = x(ind) ./ y(ind);

end

