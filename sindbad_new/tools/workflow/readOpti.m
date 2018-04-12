function [info] = readOpti(info)
%% reads configuration files for opti  and puts them into the info
% INPUT:    info
% OUTPUT:   info

% steps:
%   1) read parameters
%   2) read method to use for optimization

%% 1) read params to optimize 
paramsList = info.opti.params;
% parameter scalars to optimize
info.opti.paramsScale   	= ones(size(paramsList));

for jj=1:numel(paramsList)
    mod_param   = paramsList{jj};
    tmp         = strsplit(mod_param,'.');
    module      = tmp{1};
    paramName   = tmp{2};    
    apprName    = info.tem.model.modules.(module).apprName;
    
    try
        %read parameter info of the approaches
        paramFile       = convertToFullPaths(['./model/modules/' char(module) '/' char([module '_' apprName]) '/' char([module '_' apprName]) '.json']);
        param_json      = readJsonFile(paramFile);    
        params.(module).(paramName)   = param_json.params.(paramName);
        % make sure at least that the ranges are -Inf and +Inf
        if isnan(params.(module).(paramName).LowerBound),   params.(module).(paramName).LowerBound    = -Inf; end
        if isnan(params.(module).(paramName).UpperBound),   params.(module).(paramName).UpperBound    = +Inf; end
        % add the existing params to the list of params to optimize
        paramsList{jj} = ['p.' paramsList{jj}];
    catch
        error(['MSG: readOpti : module or parameter name not existing : ' mod_param])
    end
end

info.opti.params     = params;
info.opti.paramsList = paramsList;

%% 2) read method for optimization

info.opti.method.methodsFile	= convertToFullPaths(info.opti.method.methodsFile);
methodName                      = info.opti.method.funName;

try
method_json                     = readJsonFile(info.opti.method.methodsFile);
info.opti.method.options        = method_json.method.(methodName);
catch
    error(['MSG: readOpti : optimization method : ' methodName ' not existing in: ' info.opti.method.methodsFile ])
end

%% 3) read the cost function
info.opti.costFun.costFunsFile	= convertToFullPaths(info.opti.costFun.costFunsFile);
costFunName                     = info.opti.costFun.funName;

try
    costFun_json                     = readJsonFile(info.opti.costFun.costFunsFile);
    
    if ~isnan(costFun_json.(costFunName).funName)
        info.opti.costFun.(costFunName).funName = costFun_json.(costFunName).funName;
    else
        info.opti.costFun.(costFunName)  = costFun_json.(costFunName);
        info.opti.costFun.(costFunName) = rmfield(info.opti.costFun.(costFunName),'funName');
    end
    
catch
    error(['MSG: readOpti : cost function : ' costFunName ' not existing in: ' info.opti.costFun.costFunsFile ])
end





end