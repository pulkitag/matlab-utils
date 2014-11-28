function [Values,Ind] = getmax(A,N)
%Finds the top N elements of a multidimensional array A

ASort = sortrows([reshape(A,numel(A),1) (1:numel(A))'],-1);
Values = ASort(1:N,1);
Ind = ASort(1:N,2);

end