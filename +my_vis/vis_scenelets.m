function [] = vis_scenelets(prms,ids,hogFilter,saveFolder,varargin)
%Given a filter visualize responses in a database of images given in imdb format.
%prms.imdb: image_database
%prms.hogModel: hogModel to be used
%ids: image ids for which the hogFilter should be evaluated
%hogFilter for which response is to be generated.

%vis_scenelets
if isempty(varargin)
	%Add Paths
	addpath('~/Research/codes/codes/myutils/Matlab/vis/helper/');
	addpath(fullfile('~/Research/codes/codes/projScene','hog'));
	add_toolbox('hog_lda');
	add_toolbox('vlfeat');
	addpath('/home/eecs/pulkitag/Research/codes/codes/pkgs/voc-release5/bin');
end
%Convert hogFilter into appropriate form.
if ~iscell(hogFilter)
	hogFilter = {hogFilter};
end
nf = length(hogFilter);

%Function for features
featFnHandle = @im_max_response;

%Construct params for feature extration
prob.imdb = prms.imdb;
prob.hogModel = prms.hogModel;
prob.fast = true;

patches = cell(nf,length(ids));
scores = zeros(nf,length(ids));


filterSz = zeros(2,nf);
for i=1:1:nf
	[filterSz(1,i), filterSz(2,i), ~] = size(hogFilter{i}); 
	hogFilter{i} = single(hogFilter{i});
end


for i=1:1:length(ids)
    disp(i);
    imId = ids(i);
    im = imread(fullfile(prms.imdb.dir, prms.imdb.images.name{imId}));
    hog = compute_hog(im,prob.hogModel);
    
	[sc,lz] = featFnHandle(prob,hogFilter,ids(i));

    count = 0;
    fScores = lz.sc;
    
    for f=1:1:nf
        count = count + 1;

        %Find location where maxResponse was registered.
        scale = lz.ls(f);
        y = lz.ly(f);
        x = lz.lx(f);

        %Size of the filter
        ysz = filterSz(1,f);
        xsz = filterSz(2,f);

        sM = hog.scale(scale);
        %Note: I am using hog_lda code for hog, the output scale compensates for
        %cellSizes into pixel sizes.
        y1 = min(size(im,1),max(1,floor(sM*(y-1) + 1)));
        y2 = min(size(im,1),max(1, y1 + floor(sM*ysz)));
        x1 = min(size(im,2),max(1,floor(sM*(x-1) + 1)));
        x2 = min(size(im,2),max(1, x1 + floor(sM*xsz)));
        
        patches{f,i} = im(y1:y2,x1:x2,:);
        scores(f,i) = fScores(f);
        disp(sprintf('Score: %.3f, Scale: %.2f',scores(f,i),sM));


    end
    
end

rows = ceil(sqrt(length(ids)));
cols = rows;


for f=1:1:nf
	figure(f);
	for i=1:1:length(ids)
		subplot(rows,cols,i);
		imshow(patches{f,i});
		title(num2str(scores(f,i)));
	end
end

end
