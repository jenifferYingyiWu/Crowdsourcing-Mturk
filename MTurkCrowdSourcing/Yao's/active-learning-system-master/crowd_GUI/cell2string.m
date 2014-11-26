function [result] = cell2string(thecell)
    result = '{';

    if length(thecell)>0
        if length(thecell)>1
            for i=1:length(thecell)-1
                result = [result thecell{i} ', '];
            end
        end
       result =  [result thecell{length(thecell)}];
    end
    result = [result '}'];
end

