function [] = write_txt(FileName,format,Data,Data1)
%Writes the 2-D array Data into FileName using '\t': horizontal tab
%format: tells the type of each column.
%seperator between columns.

filename_coordinates = strcat(FileName,'.txt');
dlmwrite(filename_coordinates,Data,'delimiter','\t','newline','unix');

filename_rgba = strcat(FileName,'rgba.txt');
dlmwrite(filename_rgba,Data1,'delimiter','\t','newline','unix');
%%%%%%% OLD Version %%%%%%%%%%%%%%%%%%%%%%%%
% File = fopen(strcat(FileName,'.txt'),'w');
% [NumRows,NumCols] = size(Data);
% NumCols = NumCols + size(Data1,2);
% for i=1:1:NumRows
%     for j=1:1:NumCols-1
%         str = strcat(cell2mat(format(j)),'\t');
%         %keyboard;
%         fprintf(File,str,Data(i,j)); %Dont put a space between %f and \t C++ is sensitive to it while reading. 
%     end
%     %For the last column.
%     str = strcat(cell2mat(format(NumCols)),'\n');
%     fprintf(File,str,Data1(i,NumCols-size(Data,2)));
%     
%         
% end
%fclose(File);

end