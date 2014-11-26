function result = makeALInfo(name)
fields = getALfields(name);
result = struct;
result.('classifier') = '';
for i=1:length(fields)
   result.(fields{i}) = '';
end
end