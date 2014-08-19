function [cMat,varargout] = scores2confusion(scoreMat,gtLabels)

numClass = length(unique(gtLabels));

if(size(scoreMat,1)~=numClass && size(scoreMat,2)~=numClass)
    error('myErr:dimChk','Illegal scoreMat');
end

if(size(scoreMat,1)==numClass)
    scoreMat = scoreMat';
end

if(size(gtLabels,1)~=length(gtLabels))
    gtLabels = gtLabels';
end

[predLabels,predLabels] = max(scoreMat,[],2);

cMat = zeros(numClass,numClass);

for gtCl=1:1:numClass
    for pCl=1:1:numClass
        cMat(gtCl,pCl) = sum(predLabels==pCl & gtLabels==gtCl);
    end
    %cMat(gtCl,:) = 100*(cMat(gtCl,:)/sum(gtLabels==gtCl));
end


varargout{1} = predLabels;
end