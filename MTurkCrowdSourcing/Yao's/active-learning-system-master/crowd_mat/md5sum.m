function Digest = md5sum(data)

filename = ['/tmp/md5-' num2str(randi(100000))];

if strcmp(class(data), 'uint32')==1
    data = double(data);
end

s = size(data);

p = prod(s);
X = reshape(data, p, 1);

save(filename, 'X', '-ascii');

Digest = md5(filename);

delete(filename);

end

