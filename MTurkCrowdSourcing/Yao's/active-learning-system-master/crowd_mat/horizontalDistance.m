function hd = horizontalDistance(x1, y1, x2, y2)
%%the horizontal distance of curve (x1, y1) from curve (x2, y2). If the curve (x1,y1) is on the left side of curve (x2,y2), then this distance is 
% positive, but if it's on the right side then it's negative.
%
% Also, the output will have the same cardinality as the second curve, i.e.
% length(x2)

nn = find(~isnan(x1));
x1 = x1(nn);
y1 = y1(nn);

hd = zeros(size(y2));

warning('off', 'all');
%nz = find(x1~=0);
%x1 = x1(nz);
%y1 = y1(nz);
%model1 = barzanLinSolve(log2(x1), y1);
%x1_y2 = 2.^barzanLinInvoke(model1, y2);
%hd = verticalDistance(y2, x1_y2, y2, x2);
%    figure;
%    plot(x1, y1, 'b*:');
%    hold on;
%    plot(x2, y2, 'r*');
%    plot(x1_y2, y2, 'g*');    

%model1 = barzanLinSolve(x1, y1);
%model2 = barzanLinSolve(x2, y2);
%warning('on', 'all');

%if model1(1) < 0 && model2(1) > 0
%    hd(:) = -Inf;
%elseif model1(1) > 0 && model2(1) < 0
%    hd(:) = Inf;
%elseif model1(1) < 0 && model2(1) < 0 
%    hd = verticalDistance(y1, x1, y2, x2);
%    error('I do not know how to deal with this\n');
%else
    hd = verticalDistance(y1, x1, y2, x2);
%end


%if length(unique(y1)) < 3
%    hd = verticalDistance(y1, x1, y2, x2);
%else
%    model = barzanLinSolve(x1, y1);
%
%    x1_y2 = barzanLinInvoke(model, y2);

%    x1_y2(x1_y2<=0) = 1;

%    hd = x2 - x1_y2;
%end
end

