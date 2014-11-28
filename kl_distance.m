function [kld] = kl_distance(p1,p2)

%Make everything a column vector.
if(size(p1,1)==1)
   p1 = p1'; 
end
nDims = size(p1,1);

if(size(p2,1)~=nDims)
   p2 = p2'; 
end

assert(size(p2,1)==size(p1,1),'Dimension mismatch');

p1 = p1 + eps;
p2 = p2 + eps;
p1 = p1/sum(p1);
Z = sum(p2,1);
p2 = bsxfun(@rdivide,p2,Z);

kld = zeros(size(p2,2),1);
for i=1:1:size(p2,2)
    kld(i) = sum(p1.*log2(p1./p2(:,i)));
end

end