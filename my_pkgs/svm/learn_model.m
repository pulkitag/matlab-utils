function [model] = learn_model(prms,featMat,gtLabels,varargin)

%featMat: numExamples*numFeatures
%gtLabels: numExamples*1
%prms.cRange: Range of c to cross validate-on
%prms.accFnHandle: A function which takes in (scoreMat,gtLabels) and produces measure of accuracy.

%Get Prms
accFnHandle = prms.accFnHandle;
cRange = prms.cRange;
isHomkerMap = prms.isHomkerMap;
homkerMapN = prms.homkerMapN;
numCross = prms.numCross;
trainStr = prms.trainStr;

%Check Data
assert(all(gtLabels>0),'Only Positive Labels are accepted');
assert(all(~isnan(featMat(:))) && all(~isinf(featMat(:))),'nans or infs in featMat');
assert(size(featMat,1)==size(gtLabels,1),'Size mismatch');
featMat = double(featMat);
gtLabels = double(gtLabels);


accArr = length(cRange);
clAccCell = cell(length(cRange),1);

N = size(gtLabels,1);
numTest = ceil(N/numCross);

if prms.isValProvided
	testMat    = varargin{1};
	testLabels  = varargin{2};
	trainMat    = featMat;
	trainLabels  = gtLabels;

	assert(size(trainMat,2)==size(testMat,2),'Dimension Mismatch');

	if(isHomkerMap)
		disp('Applying HomkerMap');
		trainMat = vl_homkermap(trainMat',homkerMapN);
		testMat = vl_homkermap(testMat',homkerMapN);
		trainMat = trainMat';
		testMat = testMat';
    end
	assert(all(~isnan(trainMat(:))) && all(~isinf(trainMat(:))),'nans or infs in trainMat');
	assert(all(~isnan(testMat(:))) && all(~isinf(testMat(:))),'nans or infs in testMat');
	for j=1:1:length(cRange)
		%Train
		trainParam = sprintf(trainStr,cRange(j));
		modelCross = train(trainLabels,trainMat,trainParam);
	    
		%Predict
		switch prms.trainType
		case 'logistic'
				scores = zeros(length(testLabels),length(unique(trainLabels)));
			   [predictedLabel, accuracy, probValues] = predict(testLabels,testMat, modelCross,'-b 1');
			   scores(:,modelCross.Label') = probValues;
		case 'svm'
			   scores = zeros(length(testLabels),2);
			   [predictedLabel, accuracy, probValues] = predict(testLabels,testMat, modelCross);
				if modelCross.Label(1) == 1
			   		scores(:,1) = probValues;
					scores(:,2) = -probValues;
				else
					scores(:,1) = -probValues;
					scores(:,2) = probValues;
				end
		end
		accArr(j) = accFnHandle(scores,testLabels);
		disp(sprintf('Liblinear acc: %f, myAcc: %f',accuracy,accArr(j)));
	end
else
	%Get the permutation for cross-validation
	permutation = get_permutation(gtLabels,numCross,'normal');
	featMat = featMat(permutation,:);
	gtLabels = gtLabels(permutation,:);

	for j=1:length(cRange)
		disp(cRange(j));
		trainParam = sprintf(trainStr,cRange(j));
		accArr(j) = crossval_train(trainParam);
		disp(sprintf('Accuracy: %f at c: %f',accArr(j),cRange(j)));
	end

end
[maxAcc,maxAccIdx] = max(accArr);

    
function acc = crossval_train(crossTrainParam)
	indices = 1:1:N;
	scores = zeros(N,length(unique(gtLabels)));

	for i=1:numTest:N
		testIndices = false(N,1);
		lastLine = min(N,i + numTest-1);
		testIndices(indices(i:lastLine)) = true;
		trainIndices = ~testIndices;

		%Train Data
		trainMat = featMat(trainIndices,:);
		trainLabels = gtLabels(trainIndices);

		%Test Data
		testMat = featMat(testIndices,:);
		testLabels = gtLabels(testIndices);

		%Apply homker map is reauires
		if(isHomkerMap)
			trainMat = vl_homkermap(trainMat',homkerMapN);
			testMat = vl_homkermap(testMat',homkerMapN);
			trainMat = trainMat';
			testMat = testMat';
		end
		assert(all(~isnan(trainMat(:))) && all(~isinf(trainMat(:))),'nans or infs in trainMat');
		assert(all(~isnan(testMat(:))) && all(~isinf(testMat(:))),'nans or infs in testMat');
		modelCross = train(trainLabels,trainMat,crossTrainParam);

		%Predict
		switch prms.trainType
			case 'logistic'
		       [predictedLabel, accuracy, probValues] = predict(testLabels,testMat, modelCross,'-b 1');
				scores(testIndices,modelCross.Label') = probValues;
			case 'svm'
		       [predictedLabel, accuracy, probValues] = predict(testLabels,testMat, modelCross);
				if modelCross.Label(1) == 1
			   		scores(testIndices,1) = probValues;
					scores(testIndices,2) = -probValues;
				else
					scores(testIndices,1) = -probValues;
					scores(testIndices,2) = probValues;
				end

		end

	end

	acc = accFnHandle(scores,gtLabels);
	clear trainMat testMat trainLabels testLabels;

end

disp(sprintf('Max Accuracy of %f at c: %f',maxAcc,cRange(maxAccIdx)));


%%%%%%%%%%%%%%%%% Final Training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Final training..');
trainParam = sprintf(trainStr,cRange(maxAccIdx));
if prms.isValProvided
	featMat = cat(1,featMat,varargin{1});
	gtLabels = cat(1,gtLabels,varargin{2});
end
if(isHomkerMap)
    featMat = vl_homkermap(featMat',homkerMapN);
    featMat = featMat';
end
featMat = double(featMat);
assert(all(~isnan(featMat(:))) && all(~isinf(featMat(:))) && all(isreal(featMat(:))),'nans or infs or complex in featMat');
assert(all(~isnan(gtLabels(:))) && all(~isinf(gtLabels(:))) && all(isreal(gtLabels(:))),'nans or infs or complex in labels');

disp(sprintf('Size of final training features is (%d,%d)',size(featMat)));

modelLogistic = train(gtLabels,featMat,trainParam);
model.modelPrms =  modelLogistic;
model.acc = maxAcc;
model.isHomkerMap = isHomkerMap;
model.C = cRange(maxAccIdx);
model.trainStr = trainParam;

end









