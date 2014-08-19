function [] = image_3d(im)
%{
#im: nr*nc*nd dimensional thing
%}
[nr,nc,nd] = size(im);
numBlocks  = ceil(sqrt(nd));

imDraw = min(im(:))*ones((nr+1)*numBlocks,(nc+1)*numBlocks,'single');
rSt = 1;
cSt = 1;
for d=1:1:nd
	rEn = rSt + nr - 1;
	cEn = cSt + nc - 1;
	imDraw(rSt:rEn,cSt:cEn) = squeeze(im(:,:,d));
	
	rSt = rSt + nr + 1;
	if mod(d,numBlocks)==0
		cSt = cSt + nc + 1;
		rSt = 1;
	end	
end
imagesc(imDraw);
