function [predLabels,varargout] = test_svm_logistic(model,featMat,varargin)

computeAcc = false;
if isempty(varargin)
	gtLabels = ones(size(featMat,1),1);
else
	gtLabels = varargin{1};
	computeAcc = true;
end

prms = model.trainPrms;
scores = zeros(size(featMat,1),length(model.modelPrms.Label));
switch prms.trainType
	case 'logistic'
		[predLabels, accuracy, probValues] = predict(gtLabels,featMat, model.modelPrms,'-b 1');
		scores(:,model.modelPrms.Label') = probValues;

	case 'svm'
		[predLabels, accuracy, probValues] = predict(gtLabels,featMat, model.modelPrms);
		if model.modelPrms.Label(1)==1
			scores(:,1) = probValues;
			scores(:,2) = -probValues;
		else
			scores(:,1) = -probValues;
			scores(:,2) = probValues;
		end
end
varargout{1} = scores;


if computeAcc
	acc = model.trainPrms.accFnHandle(scores,gtLabels);
	disp(sprintf('Accuracy on test set is %f',acc));
	varargout{2} = acc;
end

end
