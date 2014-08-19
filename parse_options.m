function [strMatch] = parse_options(str,opt)
%Given a string like '-w1 23 -c 34' ..parse_options(str,'w1') will return
%'23'


if(str(end)~=' ')
    str = strcat(str,' ');
end
opt = strcat('-',opt);
idx = strfind(str,opt);
assert(length(idx)==1,'Possible Error in Parsing String');
str = str(idx+length(opt)+1:end);
idx = strfind(str,' ');
idx = idx(1);
strMatch = str(1:idx-1);

end