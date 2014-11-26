classdef ActiveLearnerExpectedModelError < ActiveLearnerProbBeingRight    
    % Our scores are Pr[current model being right] *
    % error_if_our_model_is_right + Pr[current model being wrong] * error_if_our_model_is_wrong
    % This function is used by Mozafari 2012's papers as an intermediate
    % step
        
    methods
        function obj = ActiveLearnerExpectedModelError(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerProbBeingRight(classifier, randStream, nBoots);
            obj.acronym = 'mer';
            obj.fullName = 'ExpectedModelError';
        end
            
        function expectedModelError = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            nTrain = size(trainData,1);

            expectedModelError = zeros(nTest, 1);

            [currentPredictions, originalModel] = obj.learner.trainPredict(trainWeights, trainData, trainLabel, testData);
            
            % here we multiply by -1 since the super class does the same
            % thing, so we need to cancel it out!
            prob_being_right = - calculateScores@ActiveLearnerProbBeingRight(obj, trainWeights, trainData, trainLabel, testData);

            %%% Now calculate the training errors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            parfor i=1:nTest
                %Pr[actuallabel_of_u=x]*E(T+(u,x),T+(u,x)) + (1-Pr[actuallabel_of_u=x])*E(T+(u,x),T+(u,1-x))    
                chosenLabel = currentPredictions(i);
                otherLabel = 1-chosenLabel;
                %newTrainWeights = [trainWeights; 1]; % why 1?
                %newTrainData = [trainData; testData(i,:)];
                if 1==1 % to use or not to use cross validation
                    %newTrainLabel = [trainLabel; chosenLabel];
                    trainLabelPred = obj.learner.trainIncPredict(1, testData(i,:), chosenLabel, trainData, originalModel);
                    % evaluate the error depending on whether our model is right
                    train_err_if_right = binClassError([trainLabelPred; chosenLabel], [trainLabel; chosenLabel]);
                    train_err_if_wrong = binClassError([trainLabelPred; chosenLabel], [trainLabel; otherLabel]);
                else
                    emptyData = zeros(0, size(newTrainData,2));
                    emptyLabel = zeros(0, 1);
                    train_err_if_right = errEstimateTrainCrowdCrossVal(learner, newTrainWeights, newTrainData, [trainLabel; chosenLabel], emptyData, emptyLabel, emptyData, obj.randStream);
                    train_err_if_wrong = errEstimateTrainCrowdCrossVal(learner, newTrainWeights, newTrainData, [trainLabel; otherLabel], emptyData, emptyLabel, emptyData, obj.randStream);
                end
                % the following is the expected train error if we ask the model
                expectedModelError(i,1) = prob_being_right(i)*train_err_if_right + (1-prob_being_right(i))*train_err_if_wrong;
                fprintf(1,'mer=%d \n', i);
            end

            test = expectedModelError;
            test(isnan(test)) = 1;
            assert(all(0<=test) && all(test)<=1);

            elapsed = toc(bsTime);
            fprintf(1,'ActiveLearnerExpectedModelError time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['Our scores are Pr[current model being right] * error_if_our_model_is_right + Pr[current model being wrong] * error_if_our_model_is_wrong' ...
                    '\nThis function is used by Mozafari 2012''s papers as an intermediate'];
        end
    end

    
end

