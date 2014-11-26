function results = bin3ClassError(predicted, actual, lastIndexOfTheFirstPart, relevantLabel)
% err is the ratio of mismatches between the predicted and actual!
% a.k.a. relative error

if nargin<4
    relevantLabel=1;
end

results = zeros(3,5);
%results(i,:) will be [lastIndexOfTheFirstPart accuracy recall precision f1_measure]

[miss rec prec fscore] = binClassError(predicted(1:lastIndexOfTheFirstPart,:), actual(1:lastIndexOfTheFirstPart,:), relevantLabel);
results(1,:) = [lastIndexOfTheFirstPart miss rec prec fscore];    
[miss rec prec fscore] = binClassError(predicted(lastIndexOfTheFirstPart+1:end,:), actual(lastIndexOfTheFirstPart+1:end,:), relevantLabel);
results(2,:) = [lastIndexOfTheFirstPart miss rec prec fscore];    
[miss rec prec fscore] = binClassError(predicted, actual, relevantLabel);
results(3,:) = [lastIndexOfTheFirstPart miss rec prec fscore];

end
