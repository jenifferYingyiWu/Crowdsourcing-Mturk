function [newProbMistake nTrials] = probMajorityMistake(individualMistakeProb, individualParticipation, redundancy, randStream)
simulationTime = tic;
%individualMistakeProb = ones(1, 100)' * 0.3;
%individualParticipation = ones(1, 100)';

assert(length(individualMistakeProb)==length(individualParticipation));
assert(size(individualMistakeProb,2)==1 && size(individualParticipation,2)==1);

nWorkers = length(individualMistakeProb);

nTrials = 0;
nMistakes = 0;
newProbMistake = nan;
oldProbMistake = nan;
lastTieMistake = false;
epsilon = 0.00001;

while nTrials < 50 || abs(oldProbMistake - newProbMistake)>epsilon

    oldProbMistake = newProbMistake;

    whichWorkers = randsample(randStream, nWorkers, redundancy, true, individualParticipation); % same guy might participate more than once!?
    chances = rand(randStream, redundancy, 1);

    weights = individualMistakeProb(whichWorkers);
    assert(all(~isnan(weights)));
    majorityVote  = length(find(chances<=weights));
    if majorityVote>0.5*redundancy
        nMistakes = nMistakes+1;
    elseif majorityVote == 0.5*redundancy
        if lastTieMistake
            lastTieMistake = false;
        else
            lastTieMistake = true;
            nMistakes = nMistakes + 1;
        end
    end
    nTrials = nTrials+1;
    newProbMistake = nMistakes / nTrials;
end

elapsed = toc(simulationTime);
fprintf(1, 'Simulation time for %d labels from %d workers, epsilon %f, took %d secs.\n', redundancy, nWorkers, epsilon, elapsed);

end

