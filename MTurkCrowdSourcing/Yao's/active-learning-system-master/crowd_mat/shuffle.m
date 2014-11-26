function [ output ] = shuffle(input_vector, randStream)

if ~isvector(input_vector)
    error('shuffle is only supported for vectors!');
end

if nargin == 2
    idx = randperm(randStream, length(input_vector));
else
    idx = randperm(length(input_vector));
end
output = input_vector(idx);

    
end

