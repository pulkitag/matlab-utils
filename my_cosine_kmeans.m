function [C] = my_cosine_kmeans(X,numC)

maxIter = 1000;
%X: featDim*numPoints
assert(all(~isnan(X(:))) && all(~isinf(X(:))),'Nans or infs in X');
prevObjVal = -inf;

perm = randperm(size(X,2));

%Normalize
normX = sqrt(sum(X.*X,1));
%Remove zeros
idx = normX~=0;
X = X(:,idx);
normX = normX(idx);
X = bsxfun(@rdivide,X,normX);

%Get Centers
C = X(:,perm(1:numC));

for iter=1:1:maxIter
   proj = C'*X;
   [maxp, idx] = max(proj,[],1);
   
   objVal = 0;
   %Take the weighted average of closest assignments to get the center.
   for i=1:1:numC
      cIdx = (idx==i);
      if(sum(cIdx)==0)
          disp('Empty Center');
      end
      C(:,i) = sum(bsxfun(@times,X(:,cIdx),maxp(cIdx)),2);
      %C(:,i) = sum(X(:,cIdx),2);
      C(:,i) = C(:,i)/norm(C(:,i)); 
      objVal = objVal + sum(maxp(cIdx));
   end
   disp(objVal);
   
   %assert(objVal>=(1-1e-3)*prevObjVal,'objVal cannot decrease');
   
   if(objVal<=(1+1e-6)*prevObjVal)
       break;
   end
    prevObjVal = objVal;
    
    if(iter==maxIter)
        disp('Reaching maximum number of iterations...');
    end
   
end


end