function ni = relativeImproveOverMin( X , index)

if ~isvector(X)
    error('only vectors are allowed.');
end

if nargin==1
    m = min(X);
else
    m = X(index);
end

if m>0
    %ni = (X-m) ./ m;
    ni = X ./ m;
else
    ni = nan;
end
end

