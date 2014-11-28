function [varargout] = vis_patches(patches,varargin)
%patches: patchDims*numPatches
%patchDIms should be a perfect square - ie.e we assume square patches

dfs = {'headless',false};
dfs = get_defaults(varargin, dfs, true);

[patchDim,N] = size(patches);
patchSz = floor(sqrt(patchDim));
assert(patchSz*patchSz == patchDim,'patches are not square');

nr = ceil(sqrt(N));
nrIm = nr*patchSz + (nr-1); % One pixel space between consequent patches
if strcmp(class(patches),'uint8')
	im = 128*ones(nrIm,nrIm,class(patches));
else
	im = ones(nrIm,nrIm,'single');
	minVal = min(patches(:));
	maxVal = max(patches(:));
	patches = (patches - minVal)/(maxVal - minVal);
	assert(all(patches(:)>=0) && all(patches(:)<=1),'Patches out of range');
end
count = 0;
r = 1;
c = 1;
for i=1:1:N
	im(r:r+patchSz-1,c:c+patchSz-1) =reshape(patches(:,i),[patchSz patchSz]);
	c = c + patchSz + 1;
	count = count + 1;
	if count >= nr
		c = 1;
		r = r + patchSz + 1;
		count = 0;
	end
end
varargout{1} = im;
if dfs.headless
	fig = figure('visible','off');
else
	fig = figure();
end	
imagesc(im);
colormap('gray');
varargout{2} = fig;
end
