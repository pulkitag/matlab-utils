function [ap,varargout] = ComputeAp(gtLabels,scores,varargin)

gtLabels = double(gtLabels);
assert(sum(gtLabels==1)>0,'Ground Truth Labels have no +1');
assert(length(unique(gtLabels))==2,'Only binary labels accepted');
assert(numel(gtLabels)==numel(scores),'Scores and GT labels donot have the same number of elelemnts');

dfs = {'is2007',false,'normalizedAP',false,'apN',748.8}; %normalizedAP from Hoeim's paper on analysis of objet detection errors. apN is the average number of examples per class. 748.8 is the average number of GT boxes per class in PASCAL-Det-2007.

dfs = get_defaults(varargin,dfs,true);

gtLabels(gtLabels~=1) = -1;
[sortedScores,sortedIndices] = sort(-scores);
tp = gtLabels(sortedIndices)>0;
fp = gtLabels(sortedIndices)<0;
tp = cumsum(tp);
fp = cumsum(fp);
recall = tp/sum(gtLabels>0);

if dfs.normalizedAP
	precision = (recall*dfs.apN)./(recall*dfs.apN + fp); 
else
	precision = tp./(tp + fp);
end

if dfs.is2007
	ap=0;
	for t=0:0.1:1
			p=max(precision(recall>=t));
			if isempty(p)
					p=0;
			end
			ap=ap+p/11;
	end 
else
	[ap,recall,precision] = VOCap(recall,precision);
end

varargout(1) = {recall};
varargout(2) = {precision};
end

