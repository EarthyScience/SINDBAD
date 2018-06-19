function [info] = readOpti(info)
%% reads configuration files for opti  and puts them into the info
% INPUT:    info
% OUTPUT:   info

% steps:
%   1) read parameters
%   2) read method to use for optimization

%% 1) read params to optimize 
paramsList  = info.opti.params2opti;
info.opti        =   rmfield(info.opti,'params2opti');
% paramsList  = info.opti.params;
upbounds    =   [];
lowbounds   =   [];
pdefault    =   [];


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
        
        paramFile       = convertToFullPaths([sindbadroot './model/modules/' char(module) '/' char([module '_' apprName]) '/' char([module '_' apprName]) '.json']);
        param_json      = readJsonFile(paramFile);    
        params.(module).(paramName)   = param_json.params.(paramName);
        % make sure at least that the ranges are -Inf and +Inf
        if isnan(params.(module).(paramName).LowerBound),   params.(module).(paramName).LowerBound    = -Inf; end
        if isnan(params.(module).(paramName).UpperBound),   params.(module).(paramName).UpperBound    = +Inf; end
        % add the existing params to the list of params to optimize
        paramsList{jj}              =   ['p.' paramsList{jj}];
        lowbounds                   =   [lowbounds params.(module).(paramName).LowerBound];
        upbounds                   =   [upbounds params.(module).(paramName).UpperBound];
        pdefault                   =   [pdefault params.(module).(paramName).Default];
    catch
        error(['MSG: readOpti : module or parameter name not existing : ' mod_param])
    end
end

info.opti.params.names          = paramsList;
info.opti.params.uBounds        = upbounds;
info.opti.params.uBoundsScaled  = upbounds ./ pdefault;
info.opti.params.lBounds        = lowbounds;
info.opti.params.lBoundsScaled  = lowbounds ./ pdefault;
info.opti.params.defaults       = pdefault;
info.opti.params.defScalars     = pdefault./pdefault;
% info.opti.params     = params;
info.opti.paramsList            = paramsList;

%% 2) read method for optimization

defOptionsFile                  = convertToFullPaths(info.opti.method.defaultOptimOptions);
methodName                      = info.opti.method.funName;

method_json                     = readJsonFile(defOptionsFile);
try
info.opti.method.options        = method_json.method.(methodName);
catch
    error(['MSG: readOpti : optimization method : ' methodName ' not existing in: ' defOptionsFile ])
end

%% 3) read the cost function
info.opti.costFun.costFunsFile	= convertToFullPaths(info.opti.costFun.costFunsFile);
costName                        = info.opti.costFun.costName;

try
    costFun_json                     = readJsonFile(info.opti.costFun.costFunsFile);
    info.opti.costFun.funName     = costFun_json.(costName).funName;
   
catch
    error(['MSG: readOpti : cost function : ' costName ' not existing in: ' info.opti.costFun.costFunsFile ])
end





end