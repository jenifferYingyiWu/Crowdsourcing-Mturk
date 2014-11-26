function AllData = canonicalForm(datasetFileName, classIndex, classPivotValue, featureIndices)
% Loads a dataset and turns it into a matrix in which the class is a binary
%   value with {0,1}
% datasetFileName: is the file name of the dataset to be loaded. This loaded data
%   needs to be a struct which once turned into a cell becomes a 2x1 cell.
% classIndex: is the index of the class column in the cell loaded from
%   file. The index can be either 1 or 2.
% classPivotValue: is the pivot class value. This class value will be 
%   replaced with 1 and other class values are replaced with 0.
% AllData: the canonical dataset in which the last column in the binary
%   class label
%% Example: canonicalForm('fisheriris', 1, 'setosa', [2])
%%

origStruct = load(datasetFileName);
S = struct2cell(origStruct); % to get a cell
NumericLabels=zeros(size(S{classIndex},1),1);
NumericLabels(strcmp(S{classIndex}, classPivotValue))=1;
NumericLabels(~strcmp(S{classIndex}, classPivotValue))=0;

AllData = [S{featureIndices} NumericLabels];
end

