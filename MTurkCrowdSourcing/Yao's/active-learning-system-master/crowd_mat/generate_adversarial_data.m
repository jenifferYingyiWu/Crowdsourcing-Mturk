function [X Y PK] = generate_adversarial_data(filename, randSeed, clusterSize, nClusters, dim, meanDist)

%RandStream.setDefaultStream(RandStream('mt19937ar','seed', randSeed));

sep = meanDist;
curLab = 1;
X = zeros(0, dim);
Y = zeros(0, 1);
for i=1:nClusters
    mu1 = (2*i-2)*sep;
    mu2 = (2*i-1)*sep;
    X = [X; mu1+randn(clusterSize, dim); mu2+randn(clusterSize, dim)];
    p = ones(clusterSize, 1)*curLab;
    Y = [Y; p; 1-p];
    
    if i==-1
        idx = randperm(length(Y));
        X = X(idx, :);
        Y = Y(idx, :);    
    end    
    
    %curLab = 1-curLab;
end
PK = (1:size(Y,1))';

if(dim<-2)
    figure;
    if dim==2
        plot(X(Y==1,1),X(Y==1,2),'ro')
        hold on
        plot(X(Y==0,1),X(Y==0,2),'g*')
    else if dim==1
            plot(X(Y==1,1),X(Y==1,1),'ro')
            hold on
            plot(X(Y==0,1),X(Y==0,1),'g*')
        end
    end
    axis equal
end

data = [PK Y X];
dlmwrite(filename, data, 'delimiter', ',');
fprintf(1,'primaryKeyIdx=1, realLabel=2; featuresIdx=3:%d\n', size(data,2));

end

