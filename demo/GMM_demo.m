%add vl_feat
%add gmm-fisher
%add class: @GMMTrain

%numDims*numPoints
data = randn(20,1000);

%Create GMM Obj
numCenters = 3;
gmmObj = GMMTrain(3);

%Use it to cluster
codebook = gmmObj.train(data);




