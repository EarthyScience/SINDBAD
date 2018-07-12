function [info] = setupOpti(info)
%% reads configuration files for opti  and puts them into the info
% INPUT:    info
% OUTPUT:   info

% steps:
%   1) read parameters
%   2) read method to use for optimization
%%
%% 1) read params to optimize

% read the OPTI configurations (if it exists)
if ~isempty(info.experiment.configFiles.opti)
    try
        data_json	= readJsonFile(info.experiment.configFiles.opti);
    catch
        error([pad('CRIT FILEMISS',20,'left') ' : ' pad('setupOpti',20) ' | The main optimization configuration (opti.json) is missing'])
    end
else
    error([pad('CRIT MISMATCH',20,'left') ' : ' pad('setupOpti',20) ' | runOpti in modelRun configuration file is set to true, the configuration for optimization (opti json file) is not provided in experimental setup'])
end
% read opti cofigurations
info.opti	= data_json;
info.opti.constraints.variableNames = fields(data_json.constraints.variables);

%%

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
        
        paramFile       = convertToFullPaths(info,[info.experiment.sindbadroot './model/modules/' char(module) '/' char([module '_' apprName]) '/' char([module '_' apprName]) '.json']);
        param_json      = readJsonFile(paramFile);
        params.(module).(paramName)   = param_json.params.(paramName);
        % make sure at least that the ranges are -Inf and +Inf
        if isnan(params.(module).(paramName).LowerBound),   params.(module).(paramName).LowerBound    = -Inf; end
        if isnan(params.(module).(paramName).UpperBound),   params.(module).(paramName).UpperBound    = +Inf; end
        % add the existing params to the list of params to optimize
        paramsList{jj}              =   ['p.' paramsList{jj}];
        lowbounds                   =   [lowbounds params.(module).(paramName).LowerBound];
        upbounds                    =   [upbounds params.(module).(paramName).UpperBound];
        pdefault                    =   [pdefault params.(module).(paramName).Default];
    catch
        error([pad('CRIT MODSTR',20,'left') ' : ' pad('setupOpti',20) ' | The optimized module or parameter name not exist in selected model structure, check params2opti in opti.json : ' mod_param])
    end
end

info.opti.params.names          = paramsList;
info.opti.params.uBounds        = upbounds;
info.opti.params.uBoundsScaled  = upbounds  ./ pdefault;
info.opti.params.lBounds        = lowbounds;
info.opti.params.lBoundsScaled  = lowbounds ./ pdefault;
info.opti.params.defaults       = pdefault;
info.opti.params.defScalars     = pdefault  ./pdefault;
% info.opti.params     = params;
end