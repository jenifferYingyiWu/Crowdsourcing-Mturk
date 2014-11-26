function result = getClassifiers()
fullpath = which('/Classifier.m');
dirpath = fullpath(1:strfind(fullpath, '/Classifier.m'));
listfile = dir(dirpath);

result = {};

for i=1:length(listfile)
    pos = strfind(listfile(i).name,'.m');
    if pos
       tmp = listfile(i).name();
       tmp = tmp(1:pos-1);
       if checkClass(tmp)
           result = [result,tmp]; 
       end
    end
end

end

