function [model] = train_svm_logistic(featMat,gtLabels,varargin)
%Requires liblinear - subhranshu's version!

%Default Prms
dfs = {'trainType', 'logistic', 'numCross', 5, ...
	   'cRange', [0.001 0.01 0.05 0.1 0.5 1 5 10],...
	   'isHomkerMap',false, 'homkerMapN', 3, ...
	   'accFnHandle', @mean_diagonal_acc,...
	   'valFeat', [], 'valLabels',[],...
		'prms',[]};

dfs = get_default_prms(varargin,dfs,true);

if isempty(dfs.prms)
	prms = struct();
else
	prms = dfs.prms;
end

prms.isValProvided = false;
if ~isempty(dfs.valFeat)
	valFeat = dfs.valFeat;
	valLbl  = dfs.valLabels;
	assert(~isempty(valLbl),'val labels cannot be empty');
	prms.isValProvided = true;
end

trainType = dfs.trainType;
numCross  = dfs.numCross;
cRange    = dfs.cRange;
isHomkerMap = dfs.isHomkerMap;
homkerMapN  = dfs.homkerMapN;
accFnHandle = dfs.accFnHandle;


clear dfs varargin;

if ~isfield(prms,'trainType')
	prms.trainType = trainType;
end

if ~isfield(prms,'numCross')
	prms.numCross = numCross;
end

if ~isfield(prms,'cRange')
	prms.cRange = cRange;
end

if ~isfield(prms,'isHomkerMap')
	prms.isHomkerMap = isHomkerMap;
end

if ~isfield(prms,'homkerMapN')
	prms.homkerMapN = homkerMapN;
end

if ~isfield(prms,'accFnHandle')
	prms.accFnHandle = accFnHandle;
end

if ~isfield(prms,'trainStr')
	switch prms.trainType
		case 'svm'
			prms.trainStr = '-s 3 -B 1 -c %f';
			assert(all(gtLabels == 1 | gtLabels ==2),'gtLabels must be binary');
		case 'logistic'
			%prms.trainStr = '-s 0 -B 1 -q -c %f';  %Quiet
			prms.trainStr = '-s 7 -B 1 -c %f';   %verbose
	end

end

if prms.isValProvided
	assert(all(valLbl == 1 | valLbl ==2),'valLabels must be binary');
	model = learn_model(prms,featMat,gtLabels,valFeat,valLbl);
else
	model = learn_model(prms,featMat,gtLabels);
end
model.trainPrms = prms;

end
