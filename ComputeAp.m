function [ap,varargout] = ComputeAp(gtLabels,scores,varargin)

gtLabels = double(gtLabels);
assert(sum(gtLabels==1)>0,'Ground Truth Labels have no +1');
assert(length(unique(gtLabels))==2,'Only binary labels accepted');
assert(numel(gtLabels)==numel(scores),'Scores and GT labels donot have the same number of elelemnts');

gtLabels(gtLabels~=1) = -1;
[sortedScores,sortedIndices] = sort(-scores);
tp = gtLabels(sortedIndices)>0;
fp = gtLabels(sortedIndices)<0;
tp = cumsum(tp);
fp = cumsum(fp);
recall = tp/sum(gtLabels>0);
precision = tp./(tp + fp);

ap = VOCap(recall,precision);
if(~isempty(varargin) && strcmp(varargin{1},'2007'))
   ap=0;
    for t=0:0.1:1
        p=max(precision(recall>=t));
        if isempty(p)
            p=0;
        end
        ap=ap+p/11;
    end 
end

varargout(1) = {recall};
varargout(2) = {precision};
end

