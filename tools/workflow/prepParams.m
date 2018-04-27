function [p] = prepParams(p,info)

% Usages: 
%   [p]=prepParams(p,info)
%
% Requires: 
%   info.tem.params read from config files, and (at least empty) structure p
%
% Purposes: 
%   Creates the fields of sindbad object 'p' to store the information of parameters for the
%   given modules and approaches. 
%
% Conventions: 
%   * p.[ModuleName].[ParameterName]. 
%   * The spatialization of the scalar parameters
%     should be done in the respective approaches.
%
% Created by: 
%   Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References: 
%   * 
%
% Versions: 
%   * 1.0 on 17.04.2018

%%
p = info.tem.params;
% paramsModules = fields(info.tem.params);            % a structure of modules with parameters
% for prM = 1:numel(paramsModules)
%     pModule = paramsModules{prM};
%     paramsL = fields(info.tem.params.(pModule));    % a list of parameters for the module
%     for prmLI = 1:numel(paramsL)
%         param   = paramsL{prmLI};                   % parameter value
%         evalStr = ['p.' pModule '.' param '=info.tem.params.' pModule '.' param ';'];
%         eval(evalStr)
%     end
% end
end