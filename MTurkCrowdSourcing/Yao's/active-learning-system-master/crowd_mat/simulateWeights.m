function [newWeights, newData, newLabels] = simulateWeights(TrainWeights, TrainData, TrainLabel)
TrainWeights = round(TrainWeights);
assert(size(TrainWeights,2)==1 && size(TrainWeights,1)==size(TrainData,1) && size(TrainWeights,1)==size(TrainLabel,1));

newNRows = sum(TrainWeights, 1);
newData = zeros(newNRows, size(TrainData,2));
newLabels = zeros(newNRows, 1);

rowsWritten = 0;

for i=1:size(TrainWeights,1)
    freq = TrainWeights(i);
    newData(rowsWritten+1:rowsWritten+freq,:) = repmat(TrainData(i,:), freq, 1);
    newLabels(rowsWritten+1:rowsWritten+freq,:) = repmat(TrainLabel(i), freq, 1);
    rowsWritten = rowsWritten + freq;
end

newWeights = ones(size(newLabels));
end

