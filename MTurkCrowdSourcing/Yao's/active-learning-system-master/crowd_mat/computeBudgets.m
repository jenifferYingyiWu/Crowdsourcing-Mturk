function [whatYouCanSee, budgetPerStep, budgetReportingFrequency, totalBudget] = computeBudgets(budgetStruct, nTest)
% batchingStrategy = struct('absolute_whatYouCanSee', false, 'whatYouCanSee', 0.1, 'absolute_budgetPerStep', false, 'budgetPerStep', 0.1, 'absolute_budgetReportingFrequency', false, 'budgetReportingFrequency', 0.1, 'absolute_totalBudget', false, 'totalBudget', 1);

if budgetStruct.absolute_whatYouCanSee
    assert(1 <= budgetStruct.whatYouCanSee & budgetStruct.whatYouCanSee <= nTest);
    whatYouCanSee = round(budgetStruct.whatYouCanSee);
else
    assert(0 < budgetStruct.whatYouCanSee & budgetStruct.whatYouCanSee <= 1);
    whatYouCanSee = round(budgetStruct.whatYouCanSee * nTest);
    if whatYouCanSee < 1
        whatYouCanSee = 1;
    end
end

if budgetStruct.absolute_budgetPerStep
    assert(1 <= budgetStruct.budgetPerStep & budgetStruct.budgetPerStep <= nTest);
    budgetPerStep = round(budgetStruct.budgetPerStep);
else
    assert(0 < budgetStruct.budgetPerStep & budgetStruct.budgetPerStep <= 1);
    budgetPerStep = round(budgetStruct.budgetPerStep * nTest);
    if budgetPerStep < 1
        budgetPerStep = 1;
    end
end


if budgetStruct.absolute_budgetReportingFrequency
    assert(1 <= budgetStruct.budgetReportingFrequency & budgetStruct.budgetReportingFrequency < nTest);
    budgetReportingFrequency = round(budgetStruct.budgetReportingFrequency);
else
    assert(0 < budgetStruct.budgetReportingFrequency & budgetStruct.budgetReportingFrequency < 1);
    budgetReportingFrequency = round(budgetStruct.budgetReportingFrequency * nTest);
    if budgetReportingFrequency < 1
        budgetReportingFrequency = 1;
    end
end

if budgetStruct.absolute_totalBudget
    assert(0 <= budgetStruct.totalBudget & budgetStruct.totalBudget < nTest);
    totalBudget = round(budgetStruct.totalBudget);
else
    assert(0 <= budgetStruct.totalBudget & budgetStruct.totalBudget <=1);
    totalBudget = round(budgetStruct.totalBudget * nTest);
end

assert(budgetPerStep<=totalBudget && budgetPerStep<=whatYouCanSee);

end

