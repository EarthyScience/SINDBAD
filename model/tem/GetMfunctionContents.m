function [C]=GetMfunctionContents(mpth)

fid = fopen(mpth);
C = textscan(fid, '%s', 'delimiter', '§','CommentStyle','%');
fclose(fid);
C=C{1};
%check if last line is 'end' or 'return'
if strcmp(C(end),'return') || strcmp(C(end),'end')
    C=C(2:end-1);
else
    C=C(2:end);
end
end