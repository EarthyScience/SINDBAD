function varargout = sindbadroot
% prints/outputs the sindbad root directory. For it to work, one can not change its location from $sindbadroot/tools/utils/filedir/
%
%%
% find where is the file sindbadroot
f2c = 'sindbadroot.m';
str = which(f2c,'-all');
% the sindbadroot should be 3 folders up
str = [str{1}(1:end-numel(f2c)) '../../../'];
str =str(1:end-29); %% Sujan: changes on 05.02.2020
str = strrep(getFullPath(str),'\','/');
% check that the path exists
if ~exist(str,'dir')
    error(['ERR : sindbadroot : not a valid path : ' str])
end
% define the outputs
if nargout == 0
    disp(str)
else
    varargout{1} = str;
end
end
