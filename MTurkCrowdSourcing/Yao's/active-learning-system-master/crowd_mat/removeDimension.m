function B = removeDimension(A, dim)
    S = size(A);
    assert(dim <= length(S));
    assert(S(dim)==1);
    
    S(dim) = [];
    B = reshape(A, S); 
end

