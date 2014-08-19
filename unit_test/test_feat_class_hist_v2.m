function [] = test_feat_class_hist_v2()
sz = 6;
nf = 256;
nq = 100;
numIm = 10000;
qRange = 5;
nCl = 7;

sqSz = sz*sz;

rng(3,'twister');
for iter =1:1:10
	data = randn(numIm,sz*sz*nf,'single') - 1.5;
	qns  = zeros(nq,3,'uint32');
	qns(:,1) = ceil(rand(nq,1)*nf);
	qns(:,2) = ceil(rand(nq,1)*nf);
	qns(:,3) = ceil(rand(nq,1)*qRange);
	qns      = uint32(qns);
	clIds    = uint32(ceil(rand(numIm,1)*nCl));
	dWts     = single(ones(numIm,1));

	disp('Computing using v2');
	ticv2 = tic();
	%Compute Using v2
    [hLeft,hRight,v2Res] = feat_class_hist_v2(data,nf,sz,qns,dWts,clIds,nCl);
     %feat_class_hist_v2(data,nf,sz,qns,dWts,clIds,nCl);
	tv2   = toc(ticv2);

	disp('Computing using v1');
	ticv1 = tic();
	%Compute using v1
	for n=1:1:nq
		f1 = qns(n,1);
		f2 = qns(n,2);
		qType = qns(n,3);
	
		st1 = sqSz*(f1-1) + 1;
		en1 = st1 + sqSz - 1; 
		im1 = data(:,st1:en1)' ;
	
		st2 = sqSz*(f2-1) + 1;
		en2 = st2 + sqSz - 1;
		im2 = data(:,st2:en2)';
		[hl,hr,v1Res] = feat_class_hist(im1,im2,qType,dWts,clIds,nCl);
		
		assert(all(hl==hLeft(:,n)),'hLeft dont match');
		assert(all(hr==hRight(:,n)),'hRight dont match');
		assert(all(v1Res'==v2Res(:,n)),'hRight dont match');
	end
	tv1 = toc(ticv1);

	disp(sprintf('Time old: %f, Time new: %f',tv1, tv2));
   
 
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
