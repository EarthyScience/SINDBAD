function [p]=prepParams(p,info)

% Usage: [p]=prepParams(p,info)
% Requires: info.tem.params read from config files, and (at least empty) structure p
% Purpose: Creates the fields of sindbad object 'p' to store the information of parameters for the
% given modules and approaches. 
% Conventions: p.[ModuleName].[ParameterName]. The spatialization of the scalar parameters
% should be done in the respective approaches.
% Created by: Sujan Koirala (skoirala@bgc-jena.mpg.de)
% Version: 1 on 17.04.2018

%%
paramsModules = fields(info.tem.params);
for prM = 1:numel(paramsModules)
    pModule = paramsModules{prM};
    paramsL = fields(info.tem.params.(pModule));
    for prmLI = 1:numel(paramsL)
        param   = paramsL{prmLI};
        evalStr = ['p.' pModule '.' param '=info.tem.params.' pModule '.' param ';'];
        eval(evalStr)
    end
end
