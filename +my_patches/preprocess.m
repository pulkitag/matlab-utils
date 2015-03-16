function [patches] = preprocess(patches, varargin)
%{
%patches: ndims * number of patches
%}
dfs = {'preprocType','zscore'};
dfs = get_defaults(varargin, dfs, true); 

switch dfs.preprocType
  case 'zscore'
    %Zero mean the patches
    mu      = mean(patches,1);
    patches = bsxfun(@minus,patches,mu);
    %Make them norm 1 
    z       = sqrt(sum(patches.*patches,1));
    idx     = z > 0;
    patches(:,idx) = bsxfun(@rdivide,patches(:,idx),z(idx));
    patches(:,~idx) = 0;
    %disp('Patches Z-Normalized');

    assert(~any(isnan(patches(:))),'NaNs in patches');
    assert(~any(isinf(patches(:))),'Infs in patches');

  case 'nZscore'
    disp('Normal Z-Scoring');
    %Normal Z-Score
    %Zero mean the patches
    mu      = mean(patches,1);
    %Divide by the standared deviation 
    assert(sqrt(4)==2,'Error');
    z       = sqrt(var(patches,0,1) + 10);
    idx     = z > 0;
    patches = bsxfun(@minus,patches,mu);
    patches(:,idx) = bsxfun(@rdivide,patches(:,idx),z(idx));
    patches(:,~idx) = 0;
    %disp('Patches Z-Normalized');

  case 'whiten'
    %Zero mean the patches
    mu      = mean(patches,1);
    %Divide by the standared deviation 
    assert(sqrt(4)==2,'Error');
    z       = sqrt(var(patches,0,1) + 10);
    idx     = z > 0;
    patches = bsxfun(@minus,patches,mu);
    patches(:,idx) = bsxfun(@rdivide,patches(:,idx),z(idx));
    patches(:,~idx) = 0;

    whitenMu   = prms.sample.preprocDat.whitenMu{layerNum};
    whitenMat  = prms.sample.preprocDat.whitenMat{layerNum};
    patches    = bsxfun(@minus,patches',whitenMu);
    patches    = patches*whitenMat;
    patches    = patches';

	otherwise
		error('Unrecognized pre-processing type');
end

end

