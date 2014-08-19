function [centers,varargout] = find_distinct_patches(patches,distanceFn,numC,varargin)
% patches are assumed to sorted in the desired manner. 
% patches: nDims*nPatches

centers = zeros(size(patches,1),numC);
centerIds = zeros(numC,1);

c = 1;
centers(:,c) = patches(:,1);
centerIds(c) = 1;
count = 2;
maxCount = size(patches,2);
disp(sprintf('Number of patches is %d',maxCount));

exitFlag = true;
if(~isempty(varargin))
    thresh = varargin{1};
end
deltaThresh = 0.01;

while exitFlag
    cExitFlag = false;
    reStartFlag = false;
    while ~cExitFlag
        failFlag = false;
        for i=1:1:c
            d = distanceFn(centers(:,i),patches(:,count));
            %disp(d);
            if(d<thresh)
                %disp(d);
                count = count + 1;
                failFlag = true;
                break;
            end
        end
        
        if(failFlag)
            %disp('Fail Flag');
            if(c<numC && count > maxCount)
                cExitFlag = true;
                reStartFlag = true;
                thresh = thresh - deltaThresh;
                disp(sprintf('Threshold decreased to %f',thresh));
                
            end
            
        else
            disp(count);
            c = c + 1;
            centers(:,c) = patches(:,count);
            centerIds(c) = count;
            count = count + 1;
            
            siml = distanceFn(centers(:,c),centers(:,1:c-1));
            avgSim = mean(siml);
            [maxSim,idxSim] = max(siml);
            disp(sprintf('patch Found, avg-distance: %f, max-distance: %f',avgSim,maxSim)); 
            
            if(c==numC)
                cExitFlag = true;
                exitFlag = false;
            end
            
            if(c<numC && count > maxCount)
                cExitFlag = true;
                reStartFlag = true;
                thresh = thresh - deltaThresh;
            end
        end
    end
    
    if(reStartFlag)
        disp('Restrting Computation...');
        centers = zeros(size(patches,1),numC);
        centerIds = zeros(numC,1);
        c = 1;
        centers(:,c) = patches(:,1);
        centerIds(c) = 1;
        count = 2;
    end
end

varargout{1} = centerIds;

end