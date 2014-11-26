function weightedError = binWeightedClassError(predicted, actualWeights, actual)
% err is the ratio of mismatches between the predicted and actual!
% a.k.a. relative error

if length(actual)==0 
    accuracy=NaN;
    return;
end

if any(size(predicted)~=size(actual))
    error(['Invalid size of input: ' num2str(size(predicted)) ' and ' num2str(size(actual))]);
end

if size(predicted,2)~=1 || size(actual,2)~=1
    error('only signle columns have been verified in this implementation.');
end

nTotal = size(actual,1);

mismatches = find(actual~=predicted);

weightedError = sum(actualWeights(mismatches)) / nTotal;

end

