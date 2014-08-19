function [labels] = ids2labels(imdb,ids)

numClasses = length(imdb.classes.name);
labels = zeros(length(ids),1);

for cl=1:1:numClasses
    classIds = imdb.classes.imageIds{cl};
    [classIds,ia,ib] = intersect(ids,classIds);
    labels(ia) = cl;
end

end