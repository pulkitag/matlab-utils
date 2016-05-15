stepSz = 1;

maxSz = 60;
maxPatchSz = 13;
max3D = 20;
for i=1:1:5
	nr = 20 + ceil(rand()*maxSz);
	nc = 20 + ceil(rand()*maxSz);

	rSz = 1 + ceil(rand()*maxPatchSz);
	cSz = 1 + ceil(rand()*maxPatchSz);
	if mod(rSz,2)==0
		rSz = rSz + 1;
	end
	if mod(cSz,2)==0
		cSz = cSz + 1;
	end

	nd = 3 + ceil(rand()*max3D);

	disp(sprintf('Patch Size is [%d,%d]',rSz,cSz));
	im = randn(nr,nc,nd,'single');


	numThreads = 1;
	tic();
	[dataVol,locVol] = vol2col_rect(im,rSz,cSz,stepSz,stepSz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	
	tic();
	data = cell(nd,1);
	for d=1:1:nd
		data{d} = im2col(im(:,:,d),[rSz, cSz]);
	end
	data = cat(1,data{:});
	disp(sprintf('Time for matlab: %f',toc()));
	
	assert(all(dataVol(:)==data(:)),'Error in data');
	%assert(all(locVol(:)==loc(:)),'Error in location');
end
