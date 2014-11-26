function [algRand, cmRand, baseLineRand] = computeRandSeeds(randSeed, separate)

if ~separate
    if randSeed~=-1
        algRand = RandStream('mt19937ar','seed', randSeed);
        cmRand = RandStream('mt19937ar','seed', randSeed+1);
        baseLineRand = RandStream('mt19937ar','seed', randSeed+2);
    else
        algRand = RandStream('mt19937ar', 'seed', 'shuffle');
        cmRand = RandStream('mt19937ar', 'seed', 'shuffle');
        baseLineRand = RandStream('mt19937ar', 'seed', 'shuffle');
    end
else
    if randSeed~=-1
        [algRand cmRand baseLineRand] = RandStream.create('mrg32k3a','seed', randSeed, 'NumStreams', 3);
    else
        [algRand cmRand baseLineRand] = RandStream.create('mrg32k3a','seed', 'shuffle', 'NumStreams', 3);
    end
end    

end

