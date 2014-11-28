function [varargout] = im_max_response(prob,hogFilters,imId)

hogModel = prob.hogModel;

%tFeat = tic();

%get image from imId
im = imread(fullfile(prob.imdb.dir, prob.imdb.images.name{imId}));

%get hog features
hog = compute_hog(im,hogModel);

%parameters
nf = length(hogFilters); %number of filters
k =  nf;  %topK
ns = length(hog.scale); %number of scales.

%Define the latent variables
lz.fi = zeros(k,1);
lz.ls = zeros(k,1);
lz.ly = zeros(k,1);
lz.lx = zeros(k,1);
lz.sc = zeros(k,1);

maxnx = 0;
maxny = 0;
for i=1:1:nf
	[ny,nx,~] = size(hogFilters{i});
	maxny = max(maxny,ny);
	maxnx = max(maxnx,nx);
end

%A scale is only considered if the filter with maximum size can be applied.
for s=1:1:ns
    [yLen,xLen,dd] = size(hog.feat{s});
    if(yLen<maxny || xLen<maxnx)
        ns = s-1;
        break;
    end
end



%Initialize response params
maxResponse.scale = zeros(nf,1);
maxResponse.loc = cell(nf,1);
maxResponse.score = -inf*ones(nf,1);


for s = 1:1:ns
    %compute response at 1 scale of
    %response = fconv(hog.feat{ns},sceneModel.w{cl},1,nf);
    if(prob.fast)
        response = fconv_var_dim(single(hog.feat{s}),hogFilters,1,nf);
    else
        response = fconv(hog.feat{s},hogFilters,1,nf);
    end

    for i=1:1:nf
        %For each filter find the max scoring location at scale s.
        [score,loc] = max(response{i}(:));
        [y,x] = ind2sub(size(response{i}),loc);

        %If score at current scale is the maximim.
        if(score>maxResponse.score(i))
            maxResponse.score(i) = score;
            maxResponse.scale(i) = s;
            maxResponse.loc{i} = [y,x];
        end
    end
end



sIdx = 1:1:nf;
lz.fi = sIdx;
lz.sc = maxResponse.score(sIdx);

classScore  = sum(maxResponse.score(sIdx));

for i=1:1:length(sIdx)
    scale = maxResponse.scale(sIdx(i));
    lz.ls(i) = scale;

    %location where maxResponse was registered.
    loc = maxResponse.loc{sIdx(i)};
    y = loc(1);
    x = loc(2);
    lz.ly(i) = y;
    lz.lx(i) = x;

end

varargout{1} = classScore;
varargout{2} = lz;

end
