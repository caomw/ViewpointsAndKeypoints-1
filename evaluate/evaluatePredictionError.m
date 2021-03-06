function [errors,predBest] = evaluatePredictionError(prediction,gt,encoding)

%gt = gt(randperm(size(gt,1)),:);

%Create a vector to store errors
errors = Inf(size(gt,1),1);
% Get the euler angles and rotations for the predictions
if(iscell(prediction))
    predBest = prediction{1};
    % Get the Euler angle and rotation matrix representation of the pose
    % predictions
    for i=1:length(prediction)
        eulersPred{i} = decodePose(prediction{i},encoding);
        rotsPred{i} = encodePose(eulersPred{i},'rot');
    end
else
    predBest = prediction;
    eulersPred = {decodePose(prediction,encoding)};
    rotsPred = {encodePose(eulersPred{1},'rot')};
end

% Get the euler angles and rotations for the ground truth labels
eulersGt = decodePose(gt,encoding);
rotsGt = encodePose(eulersGt,'rot');

% For each prediction compute the error
% length(rotsPred) is usually 1 (as number of hypotheses = 1)
for h=1:length(rotsPred)
    for i=1:size(gt,1)
        % Reshape the rotation matrix representation from a vector (9 x 1)
        % to a matrix (3 x 3), for the prediction and the ground truth.
        rotPred = reshape(rotsPred{h}(i,:),3,3);
        rotGt = reshape(rotsGt(i,:),3,3);
        % Take the Frobenius norm to be the error
        err = norm(logm(rotGt*rotPred'), 'fro');
        if(err < errors(i))
            errors(i)=err;
            if(h > 1)
                predBest(i,:) = prediction{h}(i,:);
            end
        end
    end
end
errors = errors/sqrt(2)*180/pi;

%error = mean(errors);
%bar(errSort);
%medianErr = median(errors);
end
