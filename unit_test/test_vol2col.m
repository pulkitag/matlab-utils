stepSz = 1;

maxSz = 60;
maxPatchSz = 13;
max3D = 20;
for i=1:1:5
	nr = 20 + ceil(rand()*maxSz);
	nc = 20 + ceil(rand()*maxSz);

	sz = 1 + ceil(rand()*maxPatchSz);
	if mod(sz,2)==0
		sz = sz + 1;
	end

	nd = 3 + ceil(rand()*max3D);


	disp(sprintf('Patch Size is [%d,%d]',sz,sz));
	im = randn(nr,nc,nd,'single');


	numThreads = 1;
	tic();
	[dataVol,locVol] = vol2col(im,sz,stepSz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	
	tic();
	data = cell(nd,1);
	for d=1:1:nd
		[data{d},loc] = im2col_fast(im(:,:,d),sz,stepSz,numThreads);
	end
	data = cat(1,data{:});
	disp(sprintf('Time for matlab: %f',toc()));
	
	assert(all(dataVol(:)==data(:)),'Error in data');
	assert(all(locVol(:)==loc(:)),'Error in location');
end
