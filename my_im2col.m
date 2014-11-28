function [patch,varargout] = my_im2col(im,sz,block_type)
%Runs im2col and additionally also outputs the patch centers in (row,column) format
rSz = sz(1);
cSz = sz(2);
assert(mod(rSz,2)==1 && mod(cSz,2)==1, 'my_im2col only works for odd-sized patches');
assert(strcmp(block_type,'sliding'),'Only supported for sliding bloc_type');
patch = im2col(im,sz,block_type);

loc = zeros(2,size(patch,2),'uint32');
if strcmp(block_type,'sliding')
	rSt = (rSz + 1)/2; rEn = size(im,1) - rSt + 1;
	cSt = (cSz + 1)/2; cEn = size(im,2) - cSt + 1;
	rows = repmat(rSt:1:rEn,1,cEn-cSt+1);
	cols = single(1:1:(rEn-rSt+1)*(cEn-cSt+1));
    cols = (cSt - 1) + ceil(cols/(rEn-rSt+1));
	loc(1,:) = uint32(rows);
	loc(2,:) = uint32(cols');
end

varargout{1} = loc;	
end
