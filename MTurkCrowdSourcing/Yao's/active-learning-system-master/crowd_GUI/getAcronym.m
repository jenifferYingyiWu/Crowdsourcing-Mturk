function result = getAcronym(name)
ALcode = fileread([name '.m']);
[startIndex,endIndex] = regexpi(ALcode,['acronym' '.*?;']);
str = ALcode(startIndex:endIndex);
result = regexp(str,'''','split');
result = result(2);
result = result{1};
end

