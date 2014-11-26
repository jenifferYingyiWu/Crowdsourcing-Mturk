function al = getALInstance(name,al_Full_map,al_info_map)
f = getALfunction(name,al_Full_map);
al_info = al_info_map.(name);

fieldname_set = fieldnames(al_info);
for i=1:length(fieldname_set)
    tmp=eval(['al_info.' fieldname_set{i}]);
    if ~isempty(tmp)
        tmp = eval(tmp);
    end
    eval([fieldname_set{i} ' = tmp;']);
end

al = eval([f ';']);

end

