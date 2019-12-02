function strPaths = convertToFullPaths(info,strPaths)
% converts the relative paths to the full path
%
% Requires:
%   - info
%   - strPaths
% Purposes:
%   - returns full path relative to the sindbadroot 
%       - if sindbadroot is specified in experiment.json
%       - or assumes directory two levels up is the root of the sindbad (works for
%       testbeds)
%   - returns the cleaned full path with slashes and so on if full path is
%   provided.
%   - works also for a collection/lists of paths
%
% Conventions:
%  - either works for full path or path relative to sindbad root two levels up
%
% Created by:
%   - unknown
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.1 on 29.10.2019 (by skoirala) : fixes the issue with full path outside the
%   sindbad root, originally would prepend sindbadroot; documentation
%   - 1.0 on unknown

%%

%%check if the sindbadroot is provided
getPathHere = false;
if ~isfield(info.experiment,'sindbadroot')
    getPathHere = true;
elseif ~exist(info.experiment.sindbadroot,'dir')
    getPathHere = true;
end
if getPathHere
    disp(['WARN PATH : convertToFullPaths : using sindbadroot() : ' sindbadroot ' : instead of info.experiment.sindbadroot : ' info.experiment.sindbadroot])
    bf = sindbadroot;
else
    bf = info.experiment.sindbadroot ;
end

%% differentiate between a string (single path) or struct/cell (a collection
% of paths)
if isstruct(strPaths)
    for fn                      =   fieldnames(strPaths)'
        if ischar(strPaths.(fn{1}))
            strPaths.(fn{1})    =   setItUp(bf,strPaths.(fn{1}));
        else
            strPaths.(fn{1})    =   convertToFullPaths(info,strPaths.(fn{1}));
        end
    end
elseif ischar(strPaths)
    strPaths                    =   setItUp(bf,strPaths);
elseif iscell(strPaths)
    for i                       =   1:numel(strPaths)
        if ischar(strPaths{i})
            strPaths{i}         =   setItUp(bf,strPaths{i});
        end
    end
else
    disp(['WARN PATH : convertToFullPaths : not a known string datatype for paths : ' class(strPaths)])
end

end

%% function to replace the slashes and add the basedir to create a full path
function str = setItUp(bf,str)
    if numel(bf) <= numel(str)
        if strncmp(strrep(bf,'\','/'),strrep(str,'\','/'),numel(bf))
            bf = '';
        end
    end
    if strcmp(getFullPath(str), str) == 1
        str = strrep(str,'\','/');
    else
        str = strrep(getFullPath([bf str]),'\','/');
    end
end
