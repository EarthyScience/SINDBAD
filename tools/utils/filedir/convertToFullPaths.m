function strPaths = convertToFullPaths(info,strPaths)
% converts the relative paths to the full path, having sindbadroot as the root folder

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

end % function
%% set the path
function str = setItUp(bf,str)
if numel(bf) <= numel(str)
    if strncmp(strrep(bf,'\','/'),strrep(str,'\','/'),numel(bf))
        bf = '';
    end
end
str = strrep(getFullPath([bf str]),'\','/');
end
