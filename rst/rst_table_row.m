function [r] = rst_table_row(colWidth,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Pulkit Agrawal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numCols = length(colWidth);
if(strcmp(type,'data'))
    r = '|';
else
    r = '+';
end
    
for c=1:1:numCols;
    switch type
        case 'header'
            r = strcat(r,repmat('=',[1 colWidth(c)]),'+');
        case 'newrow'
            r = strcat(r,repmat('-',[1 colWidth(c)]),'+');
        case 'data'
            r = sprintf('%s%s|',r,repmat(' ',[1 colWidth(c)]));
               
        otherwise
            disp('Type not available');
            break;
    end

end

r = strcat(r,'\n');

end