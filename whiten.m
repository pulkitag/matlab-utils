function [featMat,whitenMat,mu,varargout] = whiten(data,tol)
%data is expected to be in format: numExamples*numFeatures

reshapeFlag = false;
if(ndims(data)==3)
    [numEx,n1,n2] = size(data);
    assert(n1==n2,'data size is not appropriate');
    data = reshape(data,numEx,n1*n1);
    reshapeFlag=true;
end

assert(all(isreal(data(:))),'Error: Data has complex values');

mu = mean(data,1);
covMat = cov(data);
[V,D] = eig(covMat);
D = diag(D);
assert(all(isreal(V(:))),'Complex in Eigen Vectors');
if ~all(D(:)>0)
	idx = D(:) <= 0;
	disp(D(idx));
	disp('Warning: Negative Eigen Values found');
	D = max(D,0);
end

if (nargin<2)
	nz = D > 0;
    tol = 0.1*min(D(nz));
    disp(sprintf('Using a tolerance of %e',tol));
end

varargout{1} = D;
D = sqrt(1./(D + tol));
whitenMat = V*diag(D)*V';
assert(all(isreal(whitenMat(:))),'Complex in whitenMat');

%whitenMat = V*diag(D);
data = bsxfun(@minus,data,mu);
featMat = data*whitenMat;

if(reshapeFlag)
    featMat = reshape(featMat,numEx,n1,n1);
end



end
