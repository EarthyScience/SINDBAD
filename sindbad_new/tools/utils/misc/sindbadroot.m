function varargout = sindbadroot
str = 'D:/go/projects/sindbad/sindbad_new/';
str = getFullPath(str);
if~exist(str,'dir'),error(['ERR : sindbadroot : not a valid path : ' str]),end
if nargout == 0
	disp(str)
else
    varargout{1} = str;
end
