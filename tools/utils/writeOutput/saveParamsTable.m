function [outPath] = saveParamsTable(info, p, paramStruct)
% writes the full parameter table to a excel file
%
% Requires:
%   - info
%   - p: parameter structure with default or optimized values
%   - paramStruct: full paramter structure with input default and bounds to
%   write as table
%
% Purposes:
%   - save the full table of paramters 
%
% Conventions:
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 29.03.2021 (by skoirala) : 
%
%% create a table to be saved

% check if the parameters were optimized. If so, update the optim column
if isfield(info, 'opti') && isfield(info.opti,'params')
    if info.tem.model.flags.runOpti
        modules=fieldnames(info.tem.allparams);
        for mn=1:numel(modules)
            fn = modules{mn};
            pnames = fieldnames(info.tem.allparams.(fn));
            for pnum=1:numel(pnames)
                pname = pnames{pnum};
                optValue = p.(fn).(pname);
                if size(optValue, 1) > 1
                    paramStruct.optim{end+1} = 'matrix';
                else
                    paramStruct.optim{end+1} = optValue;
                end
            end
        end
        paramTable = table(paramStruct.module',paramStruct.approach', paramStruct.param', paramStruct.inOpti', paramStruct.optim', paramStruct.default', paramStruct.lbound', paramStruct.ubound', paramStruct.unit', 'VariableNames', fieldnames(paramStruct)');
    else
        paramTable = table(paramStruct.module',paramStruct.approach', paramStruct.param', paramStruct.inOpti', paramStruct.default', paramStruct.lbound', paramStruct.ubound', paramStruct.unit', 'VariableNames', fieldnames(paramStruct)');
    end
else
    paramTable = table(paramStruct.module',paramStruct.approach', paramStruct.param', paramStruct.default', paramStruct.lbound', paramStruct.ubound', paramStruct.unit', 'VariableNames', fieldnames(paramStruct)');
end

%% outPutpath for the table file
outPath     = info.opti.paths.ParamTablePath;
%% save the table
writetable(paramTable, outPath)

end
