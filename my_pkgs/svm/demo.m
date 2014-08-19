feat = randn(1000,10);
labels = ones(1000,1);
labels(501:1000) = 2;

%For logistic
%{
prms.numCross = 5;
prms.trainType = 'logistic';
model = train_svm_logistic(feat,labels);
%}

valFeat = randn(1000,10);
valLabels = ones(1000,1);
valLabels(501:1000) = 2;
prms.trainType = 'svm';
model = train_svm_logistic(feat,labels,prms,valFeat,valLabels);
