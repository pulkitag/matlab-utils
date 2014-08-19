function [ap] = mean_ap(scores,gtLabels)
	
assert(sum(gtLabels==1 | gtLabels==2)==length(gtLabels),'Something is wrong');

%Assumes the first column is the relevant one.
scores = scores(:,1);

ap = ComputeAp(gtLabels,scores);

end
