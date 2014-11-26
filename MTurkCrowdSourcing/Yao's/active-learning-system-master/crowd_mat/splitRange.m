function [ leftRange, rightRange ] = splitRange(N, leftRangeRatio)

split = round(N * leftRangeRatio);
leftRange = (1:(split-1))';
rightRange = (split:N)';

end

