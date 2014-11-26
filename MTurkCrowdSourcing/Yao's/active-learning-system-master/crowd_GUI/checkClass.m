function result = checkClass(name)
try
    s = eval(name);
    result = true;
catch err
    if (strcmp(err.identifier,'MATLAB:minrhs'))
        result = true;
    else
        result = false;
    end
end