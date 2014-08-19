for i=1:1:20
	disp(i);
	nr = 100 + ceil(rand()*20);
	nc = 100 + ceil(rand()*20);
	im = single(randn(nr,nc,3));
	[patches,loc] = vol2col(im,1,1,8);
	im1 = my_patches.patches2im(patches,nr,nc);

	assert(all(im(:)==im1(:)),'Mismatch');
end


