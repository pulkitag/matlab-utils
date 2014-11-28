%rng('default');
%rng(1);
stepSz = 2;

maxSz = 60;
maxPatchSz = 13;
max3D = 20;
for i=1:1:10
	nr = 20 + ceil(rand()*maxSz);
	nc = 20 + ceil(rand()*maxSz);

	sz = 1 + ceil(rand()*maxPatchSz);
	if mod(sz,2)==0
		sz = sz + 1;
	end
	
	border = uint32((sz-1)/2);

	nd = 3 + ceil(rand()*max3D);

	disp(sprintf('Patch Size is [%d,%d]',sz,sz));
	im = randn(nr,nc,nd,'single');


	numThreads = 1;
	tic();
	[maxVal,maxLoc] = my_patches.pool_vol_im(im,sz,stepSz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	
	tic();
	data = cell(nd,1);
	testMaxVal = cell(nd,1);
	testMaxLoc = cell(nd,1);
	mloc = zeros(2,1);
	if mod(nr -sz + 1,stepSz) ~= 0 
		poolNr = floor(single(nr - sz + 1)/single(stepSz)) + 1;
	else
		poolNr = (nr -sz + 1)/stepSz;
	end
	if mod(nc - sz +1, stepSz) ~=0
		poolNc = floor(single(nc - sz + 1)/single(stepSz)) + 1;
	else
		poolNc = (nc - sz + 1)/stepSz;
	end
	for d=1:1:nd
		[data{d},loc] = im2col_fast(im(:,:,d),sz,stepSz,numThreads);
		[testMaxVal{d},l] = max(data{d},[],1);
		
		testMaxVal{d}     = reshape(testMaxVal{d},[poolNr, poolNc]);
		rPos = uint32(mod(l,sz));
		rPos(rPos==0) = sz;
		lr = loc(1,:) - border + rPos -1;
		lc = loc(2,:) - border + uint32(ceil(l/sz)) -1;
		testMaxLoc{d} = [lr; lc]; 
	end
	data = cat(1,data{:});
	testMaxVal = cat(3,testMaxVal{:});
	testMaxLoc = cat(1,testMaxLoc{:});
	disp(sprintf('Time for matlab: %f',toc()));
	
	assert(all(maxVal(:)==testMaxVal(:)),'Error in maxValue');
	assert(all(maxLoc(:)==testMaxLoc(:)),'Error in max Location');
end
