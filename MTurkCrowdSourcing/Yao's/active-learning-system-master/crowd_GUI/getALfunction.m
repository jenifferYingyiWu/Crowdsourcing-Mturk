function result = getALfunction(name,al_Full_map)
name = al_Full_map.(name);
ALcode = fileread([name '.m']);
[startIndex,endIndex] = regexpi(ALcode,[name '[ ]*[(].*?[)]']);
result = ALcode(startIndex:endIndex);
end

