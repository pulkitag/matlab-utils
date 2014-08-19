function [perm] = get_permutation(gtLabels,numCross,permType)
%This permutation ensures that validation set has points from all classes and in the same ratio
%as present in the train distribution.
%perm: permutation which can be fed to a regular cross-vlaidation experiment, perm(1:N/5), 
%perm(N/5:2N/5) and so on will ensure the above. 

labels = unique(gtLabels);
disp(sprintf('Forming Permutation: Number of labels found: %d',length(labels)));

classIdx = cell(length(labels),1);
classSt = ones(length(labels),1);
step = zeros(length(labels),1);
for cl=1:1:length(labels)
    classIdx{cl} = find(gtLabels==labels(cl));
    step(cl) = ceil(length(classIdx{cl})/numCross);
    assert(step(cl)>0,'Error in forming permutation for training');
    if(strcmp(permType,'random'))
        p = randperm(length(classIdx{cl}));
        %disp(length(p));
        classIdx{cl} = classIdx{cl}(p);
    end
end

perm = zeros(length(gtLabels),1);
count = 1;
for i=1:1:numCross
    for cl=1:1:length(labels)
        clSt = classSt(cl);
        clEn = min(clSt+step(cl)-1,length(classIdx{cl}));
        if(clEn<clSt)
            continue;
        end
%         st = min((i-1)*step(cl) + 1,length(classIdx{cl}));
%         if(i==numCross)
%             en = length(classIdx{cl});
%         else
%             en = min(st + step(cl) - 1,length(classIdx{cl}));
%         end
        perm(count:count+clEn-clSt) = classIdx{cl}(clSt:clEn);
        count = count + clEn - clSt + 1;
        classSt(cl) = clEn + 1;

    end
end
%disp(count);
%disp(length(gtLabels));
assert(all(perm>0),'Zeros in generated permutation ..');

end
