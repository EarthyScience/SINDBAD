function strPaths = convertToFullPaths(strPaths)
if isstruct(strPaths)
    for fn = fieldnames(strPaths)'
        if ischar(strPaths.(fn{1}))
            strPaths.(fn{1}) = strrep(getFullPath([sindbadroot strPaths.(fn{1})]),'\','/');
        end
    end
elseif ischar(strPaths)
    strPaths	= strrep(getFullPath([sindbadroot strPaths]),'\','/');
elseif iscell(strPaths)
    for i = 1:numel(strPaths)
        if ischar(strPaths{i})
            strPaths{i} = strrep(getFullPath([sindbadroot strPaths{i}]),'\','/');
        end
    end
else
    error('ERR : strPaths : not a known datatype for strPaths')
end
end