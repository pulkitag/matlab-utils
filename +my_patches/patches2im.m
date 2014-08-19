function [patches] = patches2im(patches,nr,nc)
%{
# Assumes that patches is a nd*N array where N is the number of patches.
# Assumes that patches are given in colum major format. 
%}

assert(size(patches,2)==nr*nc,'Number of patches is inconsistent');
nd = size(patches,1);
patches = permute(patches,[2 1]);

patches = reshape(patches,[nr nc nd]);

end
