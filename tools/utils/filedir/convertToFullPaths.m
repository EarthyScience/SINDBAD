function strPaths = convertToFullPaths(strPaths)
if isstruct(strPaths)
    for fn = fieldnames(strPaths)'
        if ischar(strPaths.(fn{1}))
            strPaths.(fn{1}) = setItUp(strPaths.(fn{1}));%strrep(getFullPath([sindbadroot strPaths.(fn{1})]),'\','/');
        else
            strPaths.(fn{1}) = convertToFullPaths(strPaths.(fn{1}));
        end
    end
elseif ischar(strPaths)
    strPaths	= setItUp(strPaths);%strrep(getFullPath([sindbadroot strPaths]),'\','/');
elseif iscell(strPaths)
    for i = 1:numel(strPaths)
        if ischar(strPaths{i})
            strPaths{i} = setItUp(strPaths{i});%strrep(getFullPath([sindbadroot strPaths{i}]),'\','/');
        end
    end
else
    disp(['MSG : convertToFullPaths : not a known datatype for strPaths : ' class(strPaths)])
end
end
function str = setItUp(str)
bf = sindbadroot;
if numel(bf) <= numel(str)
    if strncmp(strrep(bf,'\','/'),strrep(str,'\','/'),numel(bf))
        bf = '';
    end
end
str = strrep(getFullPath([bf str]),'\','/');
end