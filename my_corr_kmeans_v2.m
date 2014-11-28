function [C] = my_corr_kmeans_v2(X,numC,numRestarts,isNrmlz)
%This is the exact copy of matlab implementation.
%X: featDim*numPoints

if ~exist('isNrmlz','var')
	isNrmlz = true;
end

maxIter = 250;
assert(all(~isnan(X(:))) && all(~isinf(X(:))),'Nans or infs in X');
iterEps = 1e-5;

%Remove points which are all zeros
normX = sqrt(sum(X.^2,1));
idx = normX~=0;
X = X(:,idx);

if isNrmlz
	%Center the points w.r.t itself.
	%%%%% OR SHOULD I DE-CENTER THE FULL DATA ? Centering wrt itself doesnt seems to be the right thing for histogram like features. Maybe good for patches, for which it is kind ofluminance invariance.
	mu = mean(X,1);
	X = bsxfun(@minus,X,mu);
	%If each point is treated as a signal, make each s.d.=1;
	%I will throw out the zero norm points. 
	normX = sqrt(sum(X.^2,1));
	idx = ~(normX <= eps(max(normX)));
	idx = idx & normX~=0;
	disp(sprintf('Num Points chosen: %d',sum(idx)));
	normX = normX(idx);
	X = X(:,idx);
	X = bsxfun(@rdivide,X,normX);
end

centersCell = cell(numRestarts,1);
objRestart = zeros(numRestarts,1);
parfor r =1:numRestarts
    [centersCell{r},objRestart(r)] = compute(X,numC,iterEps,maxIter);
end

[idx,idx] = min(objRestart);
C = centersCell{idx};

end


function [C,objVal] = compute(X,numC,iterEps,maxIter)

%Randomly select seed points.
perm = randperm(size(X,2));
C = X(:,perm(1:numC));

prevObjVal = -inf;
reTryFlag = false;
numTry = 0;

exitFlag = false;
iter = 1;

while ~exitFlag
    
    proj = C'*X;
    distance = 1 - proj;
    [maxp,idx] = min(distance,[],1);
    %[maxp, idx] = max((proj),[],1);

    objVal = 0;
    for i=1:1:numC
        cIdx = (idx==i);
        if(sum(cIdx)==0)
            disp('Empty Center');
            reTryFlag = true;
            break;
        end
        objVal = objVal + sum(maxp(cIdx));
        %objVal = objVal + mean(maxp(cIdx));

        %Re-estimate center
        C(:,i) =get_center(X(:,cIdx));
        
        if(norm(C(:,i))<=eps(1) || any(isinf(C(:,i)) | isnan(C(:,i))))
            reTryFlag = true;
            break;
        end


    end

    if(reTryFlag)
        disp('Re-Trying...');
        iter = 1;
        numTry = numTry + 1;
        perm = randperm(size(X,2));
        C = X(:,perm(1:numC));
        prevObjVal = -inf;
        if(numTry>=5)
            iterEps = 2*iterEps;
            numTry = 1;
        end

        reTryFlag = false;

    else
        disp(objVal);
        if(iter>=3 && objVal > prevObjVal)
            disp(sprintf('objVal increased from %f to %f ...should ideally decrease',prevObjVal,objVal));
        end
        if(iter>=3 && objVal>=(1-iterEps)*prevObjVal)
            exitFlag = true;
        end
        prevObjVal = objVal;
        iter = iter + 1;
    end

    if(iter==maxIter)
        disp('Reaching maximum number of iterations...');
        exitFlag = true;
    end

end


end

function [C] = get_center(X)
C = mean(X,2);
C = C - mean(C);
C = C/norm(C);
%disp(norm(C));
end
