function disp_struct(s)
    disp_struct_helper(s,1);
    fprintf('\n');
end


function disp_struct_helper(s,level)


    if isa(s,'double')
        fprintf(array2string(s));
        return;
    end

	if isa(s,'num')
        fprintf(s);
        return;
    end
    
	if isa(s,'logical')
        if s == false
            fprintf('0');
        else
            fprintf('1');
        end
        return;
    end
    
    if isa(s,'char')
        fprintf(s);
        return;
    end
    
    if isa(s, 'function_handle')
        fprintf(func2str(s));
        return;
    end
    
	if isa(s,'cell')
        fprintf(cell2string(s));
        return;
    end
    
    if isa(s,'Classifier')
        fprintf(class(s));
        return
    end
    
    if isa(s,'struct') || isa(s,'ActiveLearner')
        all_fields = fieldnames(s);
        for i=1:size(all_fields)
           tmp = [all_fields{i} ':'];
           for j=1:level
               tmp = ['    ' tmp];
           end
           fprintf(['\n' tmp]);
           disp_struct_helper(eval(['s.' all_fields{i}]),level+1);
        end
        return;
    end
    
    fprintf('cannot be displayed, not a common data type.');
    

end

