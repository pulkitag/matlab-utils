stepSz = 1;

maxSz = 50;
maxPatchSz = 13;
for i=1:1:20
	nr = 20 + ceil(rand()*maxSz);
	nc = 20 + ceil(rand()*maxSz);

	sz = 1 + ceil(rand()*maxPatchSz);
	if mod(sz,2)==0
		sz = sz + 1;
	end

	disp(sprintf('Patch Size is [%d,%d]',sz,sz));
	im = randn(nr,nc,'single');


	numThreads = 1;
	tic();
	[data,loc] = im2col_fast(im,sz,stepSz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	tic();
	[data1,loc1] = my_im2col(im,[sz sz],'sliding');
	disp(sprintf('Time for matlab: %f',toc()));
	assert(all(data1(:)==data(:)),'Error in data');
	assert(all(loc1(:)==loc(:)),'Error in location');
end
