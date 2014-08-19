function [] = test_find_tokens()
sz = 6;
numIm = 10000;

rng(3,'twister');
for iter =1:1:100

im1 = randn(sz*sz,numIm,'single') - 2 ;
im2 = randn(sz*sz,numIm,'single') - 2;
im1 = im1 > 0;
im2 = im2 > 0;

r = rand();
t1 = tic();
if r <= 0.25
	ch = 1;
elseif r <=0.50
	ch = 2;
else
	ch = 3;
end

switch ch
	case 1
		res = q1Check(im1,im2,sz);
	case 2
		res = q2Check(im1,im2,sz);
	case 3
		res = q3Check(im1,im2,sz);
end
t2 = tic();
[mexRes,debIm] = find_tokens(single(im1),single(im2),ch);
disp(sprintf('Time Matlab: %f, Mex: %f',toc(t1),toc(t2)));
disp(sprintf('Num Matches: %d, mexRes: %d, res: %d',sum(mexRes==res),sum(mexRes),sum(res)));
if ~all(mexRes==res)
	keyboard;
end
assert(all(mexRes==res),'Result Mismatch');

end

end
%Q1 Check
function res = q1Check(im1,im2,sz)
% is im2 in 1st quadrant of im1 or not

numIm = size(im1,2);
assert(numIm ==size(im2,2));
res = zeros(1,numIm,'single');
for n=1:1:numIm
	count1 = 1;
	for r1=1:1:sz
		for c1=1:1:sz
			 if im1(count1,n)>0
				isPoint = false;
				for r2=r1:-1:1
					for c2=c1+1:1:sz
						idx = (r2-1)*sz + c2;
						if im2(idx,n) > 0
							isPoint = true;
						end
					end
				end
				if (isPoint)
					res(1,n) = 1;
				end
				%Both points co-incide
				%if im2(count1,n)>0
				%	res(1,n) = 1;
				%end
			end
			count1 = count1 + 1;
		end
	end		
end
end

function res = q3Check(im1,im2,sz)
% is im2 in 3rd quadrant of im1 or not

numIm = size(im1,2);
assert(numIm ==size(im2,2));
res = zeros(1,numIm,'single');
for n=1:1:numIm
	count1 = 1;
	for r1=1:1:sz
		for c1=1:1:sz
			 if im1(count1,n)>0
				isPoint = false;
				for r2=r1:1:sz
					for c2=1:1:c1-1
						idx = (r2-1)*sz + c2;
						if im2(idx,n) > 0
							isPoint = true;
						end
					end
				end
				if (isPoint)
					res(1,n) = 1;
				end
				%Both points co-incide
				%if im2(count1,n)>0
				%	res(1,n) = 1;
				%end
			end
			count1 = count1 + 1;
		end
	end		
end
end


%Q2 Check
function res = q2Check(im1,im2,sz)
% is im2 in 2nd quadrant of im1 or not

numIm = size(im1,2);
assert(numIm ==size(im2,2));
res = zeros(1,numIm,'single');
for n=1:1:numIm
	count1 = 1;
	for r1=1:1:sz
		for c1=1:1:sz
			 if im1(count1,n)>0
				isPoint = false;
				for r2=1:1:r1-1
					for c2=1:1:c1
						idx = (r2-1)*sz + c2;
						if im2(idx,n) > 0
							isPoint = true;
						end
					end
				end
				if (isPoint)
					res(1,n) = 1;
				end
				%Both points co-incide
				%if im2(count1,n)>0
				%	res(1,n) = 1;
				%end
			end
			count1 = count1 + 1;
		end
	end		
end
end
