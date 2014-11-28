
maxSz = 50;
maxPatchSz = 13;
for i=1:1:20
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

	disp(sprintf('Patch Size is [%d,%d]',rSz,cSz));
	im = randn(nr,nc);
	[patches,loc] = my_im2col(im,[rSz cSz],'sliding');

	rSt = loc(1,:) - (rSz-1)/2;
	rEn = loc(1,:) + (rSz-1)/2;
	cSt = loc(2,:) - (cSz-1)/2;
	cEn = loc(2,:) + (cSz-1)/2;
	for j=1:1:length(loc)
		p = im(rSt(j):rEn(j),cSt(j):cEn(j));
		isTrue = p(:) == patches(:,j);	
		assert(all(isTrue),'Test Failed');
	end
	
end
disp('Test Passed');
