function info = setGenCodePaths(info)

% unique name for the generated code files according to experiment name and to runDate.
tmpStrName	= [info.experiment.name '_' info.experiment.domain '_' info.experiment.runDate];
tmpStrName  = strrep(strrep(tmpStrName,' ','_'),'-','_');

% feed that into the structure
for n1 = {'model','spinup'}
    str1 = '';
    if strcmp(n1{1},'spinup'),str1='_Spinup';end
    for n2 = {'coreTEM','preCompOnce'}
        str2 = 'Core';
        if strcmp(n2{1},'preCompOnce'),str2='PrecOnce';end
        feedIt = true;
        if isfield(info.tem.(n1{1}).paths,'genCode')
            if isfield(info.tem.(n1{1}).paths.genCode,n2{1})
                if~isempty(info.tem.(n1{1}).paths.genCode.(n2{1}))
                    feedIt = true;
                end
            end
        end
        if feedIt
            info.tem.(n1{1}).paths.genCode.(n2{1})	= convertToFullPaths([sindbadroot info.tem.model.paths.runDir 'gen' str2 str1 '_' tmpStrName '.m']);
        end
    end
end
end
