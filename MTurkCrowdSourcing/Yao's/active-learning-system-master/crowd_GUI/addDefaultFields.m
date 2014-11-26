function result = addDefaultFields(conf, dsname)
result = conf;
if ~isfield(result, 'primaryKeyCol')
    result.primaryKeyCol = 1;
end

if ~isfield(result, 'classCol')
    result.classCol = 2;
end
if ~isfield(result, 'crowdUserCols')
    result.crowdUserCols = [];
end
if ~isfield(result, 'crowdLabelCols')
    result.crowdLabelCols = [];
end
if ~isfield(result, 'fakeCrowd')
    result.fakeCrowd = true;
end
if ~isfield(result, 'balancedLabels')
    result.balancedLabels = false;
end
if ~isfield(result, 'initialTrainRatio')
    result.initialTrainRatio = 0.03;
end
if ~isfield(result, 'datafile')
    result.datafile = [dsname '.vis'];
end
if ~isfield(result, 'featureCols')
    error(['Unknown feature set for' dsname]);
end

end

