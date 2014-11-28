function [] = get_tex_figure(fName,imgName,caption,imgLabel)
%Generate Matlab figures.
scale=0.50;
figStr =  sprintf('%s%f%s','\includegraphics[scale=',scale,']');
fprintf(fName,'%s\n','\begin{figure}[!ht]');
fprintf(fName,'%s\n','\centering');

for i=1:1:length(caption)
    %fprintf(fName,'%s %s %s %s %s %s %s\n','\subfloat[',caption{i},']{',figStr,'{', imgName{i}, '}}  \hfill');
    if(rem(i,2)==1)
        fprintf(fName,'%s %s %s %s %s%s%s\n','\subfloat[',caption{i},']{',figStr,'{', imgName{i}, '}}');
    else
        fprintf(fName,'%s %s %s %s %s%s%s\n','\subfloat[',caption{i},']{',figStr,'{', imgName{i}, '}} \vfill');
    end
end

fprintf(fName,'%s %s\n','\caption{',imgLabel,'}');
fprintf(fName,'%s \n','\end{figure}');
fprintf(fName,'%s \n\n','\clearpage');
end


