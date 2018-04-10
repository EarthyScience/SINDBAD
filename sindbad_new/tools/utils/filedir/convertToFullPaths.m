function strPaths = convertToFullPaths(strPaths)
if isstruct(strPaths)
    for fn = fieldnames(strPaths)'
        if ischar(strPaths.(fn{1}))
            strPaths.(fn{1}) = strrep(getFullPath([sindbadroot strPaths.(fn{1})]),'\','/');
        else
            strPaths.(fn{1}) = convertToFullPaths(strPaths.(fn{1}));
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
    disp(['MSG : convertToFullPaths : not a known datatype for strPaths : ' class(strPaths)])
end
end