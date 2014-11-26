function [accuracy, recall, precision, f1_measure] = binClassError(predicted, actual, relevantLabel)
% err is the ratio of mismatches between the predicted and actual!
% a.k.a. relative error

if nargin<3
    relevantLabel=1;
end

if relevantLabel~=0 && relevantLabel~=1 
    error(['Invalid relevant label: ' num2str(relevantLabel)]);
end

if length(actual)==0 
    accuracy=NaN; recall=NaN; precision=NaN; f1_measure=NaN;
    return;
end

if any(size(predicted)~=size(actual))
    error(['Invalid size of input: ' num2str(size(predicted)) ' and ' num2str(size(actual))]);
end

if size(predicted,2)~=1 || size(actual,2)~=1
    error('only signle columns have been verified in this implementation.');
end

nTotal = size(actual,1);

mismatches = actual(actual~=predicted);

nErr = size(mismatches,1);

accuracy = 1 - nErr / nTotal;

ActualPositives = actual(actual==relevantLabel);
PredictedAsPositives = predicted(predicted==relevantLabel);

nActualPositives = length(ActualPositives);
nPredictedAsPositives = length(PredictedAsPositives);

PredictionsForActualPositives = predicted(actual==relevantLabel);

nTruePositives = length(PredictionsForActualPositives(PredictionsForActualPositives==relevantLabel));
nFalseNegatives = nActualPositives - nTruePositives;

ActualLabelsForPredictedAsPositives = actual(predicted==relevantLabel);
nFalsePositives = length(ActualLabelsForPredictedAsPositives(ActualLabelsForPredictedAsPositives~=relevantLabel));
nTrueNegatives = nTotal-nPredictedAsPositives - nFalseNegatives;

recall = nTruePositives / (nTruePositives+nFalseNegatives);
precision = nTruePositives / (nTruePositives+nFalsePositives);

if accuracy==1
    if isnan(recall); recall=1; end
    if isnan(precision); precision=1; end
end

f1_measure = harmmean([recall precision]);

end

