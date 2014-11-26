function vd = verticalDistance(x1, y1, x2, y2, extrapolate)
%% Returns the distance of curve (x1,y1) from curve (x2, y2). If
% y2 is larger than y1, this distance is positive, otherwise it is
% negative.
%
% Also, the output will have the same cardinality as the second curve, i.e.
% length(x2)

if ~isvector(x1) || ~isvector(x2) || any(size(x1)~=size(y1)) || any(size(x2) ~= size(y2))
    error('Vertical Distance arg mismatch.');
end

method = 'linear';

if nargin == 5
    extrap = extrapolate;
else
    extrap = 'extrap';
end

nn = find(~isnan(x1));
x1 = x1(nn);
y1 = y1(nn);

%nnn = find(~isnan(x2));
%x2 = x2(nnn);
%y2 = y2(nnn);


if size(x1, 2) == 1 %column vectors
    temp = sortrows([x1 y1]);
    sx1 = temp(:, 1);
    sy1 = temp(:, 2);
else %row vectors
    temp = sortrows([x1' y1']);
    sx1 = temp(:, 1)';
    sy1 = temp(:, 2)';
end

[ux1, m, n] = unique(sx1, 'first');
uy1 = sy1(m); 

if length(ux1)>1
    %warning('off', 'all');
    y1_x2 = interp1(ux1, uy1, x2, method, nan);
    %warning('on', 'all');
else
    y1_x2 = zeros(size(x2));
    y1_x2(:) = nan;
end
vd = y2 - y1_x2;

%the following line is to make sure that when only the origin matches, we
%don't think that they're equal!
found = find(~isnan(vd));
if length(found)==1 && vd(found)==0
    vd(found) = nan;
end

end

