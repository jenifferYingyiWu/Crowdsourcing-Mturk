function result = getALfields(name)

result = {};
ALcode = fileread([name '.m']);
[startIndex,endIndex] = regexpi(ALcode,[name '[ ]*[(].*?[)]']);

str = ALcode(startIndex:endIndex);
result = regexp(str,'[ ]*[,)(][ ]*','split');
result(:,1) = [];
result(:,length(result)) = [];

for i=1:length(result)
   if strcmp(result{1,i},'classifier')
       result(:,i) = [];
       break;
   end
end

end

