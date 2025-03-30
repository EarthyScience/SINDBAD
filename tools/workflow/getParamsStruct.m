function [paramStruct] = getParamsStruct(info)
% get the structure with full parameter information
%
% Requires:
%   - info
%
% Purposes:
%   - create a struct with the parameters and their default information 
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
%% create a struct and define fields

paramStruct=struct;
paramStruct.module={};
paramStruct.approach={};
paramStruct.param = {};
if isfield(info, 'opti') && isfield(info.opti,'params')
    paramStruct.inOpti={};
    if info.tem.model.flags.runOpti
        paramStruct.optim={};
    end
end
paramStruct.default={};
paramStruct.lbound={};
paramStruct.ubound={};
paramStruct.unit={};

%% get the values from info and put in the params struct
modules=fieldnames(info.tem.allparams);
for mn=1:numel(modules)
    fn = modules{mn};
    pnames = fieldnames(info.tem.allparams.(fn));
    for pnum=1:numel(pnames)
        pname = pnames{pnum};
        paramStruct.module{end+1} = fn;
        paramStruct.approach{end+1} = info.tem.model.modules.(fn).apprName;
        paramStruct.param{end+1} = pname;
        if isfield(info, 'opti') && isfield(info.opti,'params')
            paramStruct.inOpti{end+1} = max(ismember(info.opti.params.names,['p.' fn '.' pname]));
        end
        defValue = info.tem.allparams.(fn).(pname).Default;
        if size(defValue, 1) > 1
            paramStruct.default{end+1} = 'matrix';
            paramStruct.lbound{end+1} = 'matrix';
            paramStruct.ubound{end+1} = 'matrix';
        else
            paramStruct.default{end+1} = defValue;
            paramStruct.lbound{end+1} = info.tem.allparams.(fn).(pname).LowerBound;
            paramStruct.ubound{end+1} = info.tem.allparams.(fn).(pname).UpperBound;
        end
        paramStruct.unit{end+1} = info.tem.allparams.(fn).(pname).Unit;
    end
end

end
