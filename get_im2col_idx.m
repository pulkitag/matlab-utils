function [idx] = get_im2col_idx(r,c,patchSz,imSz,block_type)
%RGiven that patchSz patches were extracted using im2col, given row and col nums (r,c) find the indices
%of corresponding patches, i.e. which i s.t. patch(:,i) is centered at (r,c)
rSz = patchSz(1);
cSz = patchSz(2);
assert(mod(rSz,2)==1 && mod(cSz,2)==1, 'get_im2col_idx only works for odd-sized patches');
assert(strcmp(block_type,'sliding'),'Only supported for sliding bloc_type');
assert(length(r)==length(c),'Lenghts of r and c must be same');

idx = zeros(1,length(r),'uint32');
if strcmp(block_type,'sliding')
	rSt = (rSz + 1)/2; rEn = imSz(1) - rSt + 1;
	cSt = (cSz + 1)/2; cEn = imSz(2) - cSt + 1;
	assert(all(r>=rSt) && all(r<=rEn),'Patches not found for some row indices');
	assert(all(c>=cSt) && all(c<=cEn),'Patches not found for some col indices');
	rLen = rEn - rSt + 1;
	cLen = cEn - cSt + 1;
	idx = (c-cSt)*rLen + r - rSt + 1;
end

end
