function value = getFieldValueOrDefault(input_struct, field_name, default_value)

if isfield(input_struct, field_name)
    value = eval(['input_struct.' field_name]);
else
    value = default_value;
end

end

