function [imOut] = conv3d(im, filters, varargin)
%{
% Performs 3D convolution.
% filters: cell of length N, where each element is a 3D filter.  
%}

dfs = {'stepSz',1,'nThread',8, 'preprocType','none'};
dfs = get_defaults(varargin, dfs, true);

N     = length(filters); 
imOut = cell(N,1);
for i=1:1:N
	%The filters are assumed to be square.
	fltr = single(filters{i});
	[h,w,ch] = size(fltr);
	assert(h==w,'Assumed square filters');
	%Extract patches
  [patches,loc] = vol2col(single(im),h,...
          dfs.stepSz,dfs.nThread);

	if ~strcmp(dfs.preprocType, 'none')
		patches = my_patches.preprocess(patches,{'preprocType', dfs.preprocType}); 
	end	

  nr = floor((size(im,1)-h)/dfs.stepSz + 1);
  nc = floor((size(im,2)-h)/dfs.stepSz + 1);

	%Get the scores
  scores  = reshape(fltr, [1, h * w * ch]) * patches;

  %Convert back to image
  %disp(sprintf('Size im: (%d,%d,%d) Size scores: (%d,%d)',size(im),size(scores)));
  imOut{i} = my_patches.patches2im(scores,nr,nc);
end
