function [acc] = mean_diagonal_acc(scores,gtLabels)
	
	classes = unique(gtLabels);
	clAcc = zeros(length(classes),1);

	%Get Predicted labels
	[~,labels] = max(scores,[],2);
	
	%disp(size(gtLabels));
	%disp(size(labels));	
	for cl=1:1:length(classes)
		clAcc(cl) = sum(gtLabels==classes(cl) & labels==classes(cl))/sum(gtLabels==classes(cl));
	end

	acc = mean(clAcc);
	
end
