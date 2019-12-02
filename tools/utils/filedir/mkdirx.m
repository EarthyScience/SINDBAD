function mkdirx(tmp)
% creates a directory
%
% Requires:
%   - a directory path
%
% Purposes:
%   - a function to create a directory only when it does not exists
%       gets rid of an unnecessary warning when an existing directory is created
%       again
%
% Conventions:
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 11.11.2019

%%
if~exist(tmp,'dir'),mkdir(tmp);end
end