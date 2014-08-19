function [] = mat2rst(data,outFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data should be struct. 
%Each field of struct should be cell or an array.
%Cells for string values and array for numeric.
%Author: Pulkit Agrawal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('/home/eecs/pulkitag/Research/codes/codes/myutils/Matlab/rst/');

colNames = fieldnames(data);
numRows = length(data.(colNames{1}));
numCols = length(colNames);
colWidth = zeros(numCols,1);
colSt = zeros(numCols,1);
for c=1:1:numCols
    maxStrLen = length(colNames{c});
    var = data.(colNames{c});
	disp(colNames{c});
    for r = 1:1:numRows
       if(iscell(var))
           str = var{r};
       else
           if(isfloat(var))
                str = sprintf('%0.4f',(var(r)));
            else
                str = num2str(var(r));
            end
       end
       if(length(str)>maxStrLen)
           maxStrLen = length(str);
       end
   end
    
    colWidth(c) = maxStrLen + 2;
    if(c==1)
        colSt(c) = 3;
    else
        colSt(c) = colSt(c-1) + colWidth(c-1) + 1;
    end
    
end
            
outFile = fopen(outFileName,'w+');

%Form the header
rowStr = rst_table_row(colWidth,'newrow');
fprintf(outFile,rowStr);
rowStr = rst_table_row(colWidth,'data');
for c=1:1:numCols
    str = colNames{c};
    rowStr(colSt(c):colSt(c)+length(str)-1) = str;
end
fprintf(outFile,rowStr);
rowStr = rst_table_row(colWidth,'header');
fprintf(outFile,rowStr);

%Put the data
for r=1:1:numRows
    rowStr = rst_table_row(colWidth,'data');
    for c=1:1:numCols
        var = data.(colNames{c});
        if(iscell(var))
           str = var{r};
        else
            if(isfloat(var))
                str = sprintf('%0.4f',(var(r)));
            else
                str = num2str(var(r));
            end
                
        end
        rowStr(colSt(c):colSt(c)+length(str)-1) = str;
    end
   fprintf(outFile,rowStr);
   rowStr = rst_table_row(colWidth,'newrow');
   fprintf(outFile,rowStr);
   
end

fclose(outFile);

end
