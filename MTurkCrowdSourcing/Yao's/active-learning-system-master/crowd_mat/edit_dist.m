function d = edit_dist(s,t) %s,t = arrays of strings

n = length(s);
m = length(t);

if n==0
    d=m;
    exit;
end

if m==0
    d=n;
    exit;
end

M =zeros(m+1,n+1);

M(1,:) = (0:n);
M(:,1) = (0:m);

for j=2:n+1
    for i=2:m+1;
        if s(j-1)==t(i-1)
            cost=0;
        else
            cost=1;
        end
        M(i,j) = min([M(i-1,j)+1,M(i,j-1)+1,M(i-1,j-1)+cost]);
    end
end

d = M(m+1,n+1);

end