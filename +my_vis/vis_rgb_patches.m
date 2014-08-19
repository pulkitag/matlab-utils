function [varargout] = vis_rgb_patches(patches,varargin)
%patches are dims*numPatches where 1:dims/3 contain nx, dims/3+1:2dims/3: ny and so on.

assert(mod(size(patches,1),3)==0,'Normal patches should have 3 channels corr to nx,ny,nz');

normals = cell(3,1);
dim = size(patches,1)/3;
numPatches = size(patches,2);

patchSz = floor(sqrt(dim));
assert(dim==patchSz*patchSz,'patch should be square');

for i=1:1:3
	st = (i-1)*dim + 1;
	en = st + dim - 1;
	normals{i} = shiftdim(reshape(patches(st:en,:),[patchSz patchSz numPatches]),2);
end
normals = cat(4,normals{:});
disp(size(normals));
V = cell(numPatches,1);

maxVal  = max(normals(:));
minVal  = min(normals(:));
normals = (normals -minVal)/(maxVal - minVal);
disp(max(normals(:)));
disp(min(normals(:)));
for i=1:1:numPatches
	N = squeeze(normals(i,:,:,:));
	%N = N(:,:,[3,1,2]);
	V{i} = N;
end

nr = ceil(sqrt(numPatches));
nrIm = nr*patchSz + (nr-1); % One pixel space between consequent patches
im = zeros(nrIm,nrIm,3,'single');
count = 0;
r = 1;
c = 1;
for i=1:1:numPatches
	im(r:r+patchSz-1,c:c+patchSz-1,:) = V{i};
	c = c + patchSz + 1;
	count = count + 1;
	if count >= nr
		c = 1;
		r = r + patchSz + 1;
		count = 0;
	end
end
varargout{1} = [];
if isempty(varargin)
	fig = figure();
	imagesc(im);
	varargout{1} = fig;
elseif ~varargin{1}
	varargout{1} = im;
end

end
