function [C] = my_corr_kmeans(X,numC,numRestarts)

%X: featDim*numPoints

maxIter = 250;
assert(all(~isnan(X(:))) && all(~isinf(X(:))),'Nans or infs in X');

%Normalize
normX = sqrt(sum(X.*X,1));
idx = normX~=0;
X = X(:,idx);
normX = normX(idx);
X1 = bsxfun(@rdivide,X,normX);


centersCell = cell(numRestarts,1);
objRestart = zeros(numRestarts,1);

for r =1:1:numRestarts
    perm = randperm(size(X,2));
    C = X1(:,perm(1:numC));
    prevObjVal = -inf;
    reTryFlag = false;
    numTry = 0;
    eps = 1e-5;
    
    for iter=1:1:maxIter
        proj = C'*X;
        [maxp, idx] = max(proj,[],1);

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
            C(:,i) = mean(X(:,cIdx),2);
            C(:,i) = C(:,i)/norm(C(:,i));


        end

        if(reTryFlag)
            disp('Re-Trying...');
            iter = 1;
            numTry = numTry + 1;
            perm = randperm(size(X,2));
            C = X1(:,perm(1:numC));
            prevObjVal = -inf;
            if(numTry>=5)
                eps = 2*eps;
                numTry = 1;
            end
            
            reTryFlag = false;

        else
            disp(objVal);
            if(objVal<=(1+eps)*prevObjVal)
                break;
            end
            prevObjVal = objVal;
        end

        if(iter==maxIter)
            disp('Reaching maximum number of iterations...');
        end

    end
    
    objRestart(r) = objVal;
    centersCell{r} = C;
end

[idx,idx] = max(objRestart);
C = centersCell{idx};

end