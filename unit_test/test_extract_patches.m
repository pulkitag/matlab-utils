stepSz = 1;

maxSz = 120;
maxPatchSz = 13;
max3D = 20;
nPatches = 2000;
for i=1:1:10
	nr = 20 + ceil(rand()*maxSz);
	nc = 20 + ceil(rand()*maxSz);
	nd = 3 + ceil(rand()*max3D);

	sz = 1 + ceil(rand()*maxPatchSz);
	if mod(sz,2)==0
		sz = sz + 1;
	end

	disp(sprintf('Patch Size is [%d,%d]',sz,sz));
	im = randn(nr,nc,nd,'single');
	maxRow = nr - sz;
	maxCol = nc - sz;
	maxLoc = min(maxRow,maxCol);
	loc = uint32(ceil(rand(2,2000)*maxLoc));


	numThreads = 1;
	tic();
	dataVol = extract_patches(im,loc,sz,numThreads);
	disp(sprintf('Time for mex: %f',toc()));
	
	tic();
 	data = zeros(sz*sz*nd,nPatches);
	for n=1:1:nPatches
		dat = im(loc(1,n):loc(1,n)+sz-1,loc(2,n):loc(2,n)+sz-1,:);
		data(:,n) = dat(:);
	end
	disp(sprintf('Time for matlab: %f',toc()));
	
	assert(all(dataVol(:)==data(:)),'Error in data');
end
