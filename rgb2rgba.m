function [img_rgba] = rgb2rgba(img,varargin)

%Set the value of opacity (a) 
switch nargin
    case 1
        a = 128;
    case 2
        a = varargin{1};
end

img = uint32(img);
a_img = uint32(a*ones(size(img,1),size(img,2)));
%img_rgba = uint32(zeros(size(img,1),size(img,2)));
img_rgba = bitshift(a_img,24) + bitshift(img(:,:,1),16) + bitshift(img(:,:,2),8) + img(:,:,3); 
img_rgba = squeeze(img_rgba);
end