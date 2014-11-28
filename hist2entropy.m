function entropy = hist2entropy(histogram)
%{
# Computes the entropy  given the histrogram
%}

sumHist = sum(histogram(:));
entropy = 0;
if sumHist ==0
	return;
end

histogram = histogram/sumHist;
idx = histogram~=0;

histogram = histogram(idx);
entropy  = -sum(histogram.*log2(histogram));

end
