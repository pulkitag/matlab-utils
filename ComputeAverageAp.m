function [out,ap] = ComputeAverageAp(gtLabels,scores,varargin)
%Compute Average Ap across classes.
out = 0;
numClasses = 10;
%const = GetConstants(varargin{:});
%vocClasses = const.vocClasses;
assert(size(scores,2)==numClasses,'Dimension Mismatch while computing average Ap')
numExamples = size(gtLabels,1);

apArray = zeros(numClasses,1);
for i=1:1:numClasses
    gtClassLabels = -1*ones(numExamples,1);
    gtClassLabels(gtLabels==i) = 1;
    apArray(i) = ComputeAp(gtClassLabels,scores(:,i));
	%disp(apArray(i));    
end

ap = mean(apArray);
out = 1;
end

