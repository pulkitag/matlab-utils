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

	disp(sprintf('Patch Size is [%d,%d,%d]',rSz,cSz,nd));
	im   = randn(nr,nc,nd,'single');
  ptch = randn(rSz,cSz,nd,'single');
  mask = rand(rSz, cSz, 'single');
  idx  = mask < 0.5;
  mask(idx) = 0;
  mask(~idx) = 1;
  mask       = single(mask);

	numThreads = 1;
	tic();
	[dataVol,locVol] = ssd(im,ptch,mask,stepSz,stepSz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	
	tic();
	data = cell(nd,1);
	for d=1:1:nd
		data{d} = im2col(im(:,:,d),[rSz, cSz]);
	end
  repMask = repmat(mask, [1, 1, nd]);
	data = cat(1,data{:});
  diff = bsxfun(@minus, data, ptch(:));
  diff = bsxfun(@times, diff, repMask(:));
  diff = sum(diff .* diff,1);
	disp(sprintf('Time for matlab: %f',toc()));

  %keyboard;	
	assert(all(dataVol(:)==diff(:)),'Error in data');
	%assert(all(locVol(:)==loc(:)),'Error in location');
end
