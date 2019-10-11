function strPaths = convertToFullPaths(info,strPaths)
% converts the 

%%
if isstruct(strPaths)
    for fn                      =   fieldnames(strPaths)'
        if ischar(strPaths.(fn{1}))
            strPaths.(fn{1})    =   setItUp(info,strPaths.(fn{1}));   
        else
            strPaths.(fn{1})    =   convertToFullPaths(info,strPaths.(fn{1}));
        end
    end
elseif ischar(strPaths)
    strPaths                    =   setItUp(info,strPaths);                       
elseif iscell(strPaths)
    for i                       =   1:numel(strPaths)
        if ischar(strPaths{i})
            strPaths{i}         =   setItUp(info,strPaths{i});           
        end
    end
else
    disp(['WARN PATH : convertToFullPaths : not a known string datatype for paths : ' class(strPaths)])
end
end
function str = setItUp(info,str)
% sets up the str 
%%
% bf = sindbadroot; % sujan. Avoid extra calls. Already set in stampExperiment
bf = info.experiment.sindbadroot ;
if numel(bf) <= numel(str)
    if strncmp(strrep(bf,'\','/'),strrep(str,'\','/'),numel(bf))
        bf = '';
    end
end
str = strrep(getFullPath([bf str]),'\','/');
end