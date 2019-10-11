function [info] = setupOpti(info)
% setups the optimization part of the info 
%
% Requires:
%	- an info structure
%
% Purposes:
%   - setups the the opti part of the info 
%   - based on the opti configuration file
%   - reads configuration files 
%
% steps:
%   1) read opti.json
%   2) define constraints
%   3) define parameters to optimize
%
% Conventions:
%   - needs to be run where the repository is
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - v1.1: Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% References:
%
% Versions:
%   - 1.1 on 09.01.2019

%% 1) read the OPTI configuration
if ~isempty(info.experiment.configFiles.opti)
    try
        data_json	= readJsonFile(info.experiment.configFiles.opti);
        info.opti	= data_json;
    catch
        error([pad('CRIT FILEMISS',20,'left') ' : ' pad('setupOpti',20) ' | The main optimization configuration (opti.json) is missing'])
    end
else
    error([pad('CRIT MISMATCH',20,'left') ' : ' pad('setupOpti',20) ' | runOpti in modelRun configuration file is set to true, the configuration for optimization (opti json file) is not provided in experimental setup'])
end

%% 2) define constraints
info.opti.constraints.variableNames = fields(data_json.constraints.variables);

%% 3) define parameters to optimize
paramsList  = info.opti.params2opti;
info.opti        =   rmfield(info.opti,'params2opti');
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
        
        % check if alternative bounds are provided in the param.json
        param_settings = readJsonFile(info.experiment.configFiles.params);
        % check for provided bounds
        if isfield(param_settings, 'bounds')
            % check for the current module 
           if isfield(param_settings.bounds, module)
               % check for the current approach
              if isfield(param_settings.bounds.(module), paramName)
                  % check for the lower bounds
                  if isfield(param_settings.bounds.(module).(paramName), 'LowerBound')
                     params.(module).(paramName).LowerBound = param_settings.bounds.(module).(paramName).LowerBound;
                     disp(['lower bound for parameter ' module '.' paramName ' is changed  to: ' num2str(param_settings.bounds.(module).(paramName).LowerBound)]); 
                  end
                  % check for the upper bound
                  if isfield(param_settings.bounds.(module).(paramName), 'UpperBound')
                     params.(module).(paramName).UpperBound = param_settings.bounds.(module).(paramName).UpperBound;
                     disp(['upper bound for parameter ' module '.' paramName ' is changed  to: ' num2str(param_settings.bounds.(module).(paramName).UpperBound)]); 
                  end 
              end
           end    
        end
        
        % check if optimization should start from the default value or if
        % it has been changed in info.tem.params
        if isequal(info.tem.params.(module).(paramName), params.(module).(paramName).Default)
            pdefault            =   [pdefault params.(module).(paramName).Default];
        else
            pdefault            =   [pdefault info.tem.params.(module).(paramName)];
        end
        
       
        % add the existing params to the list of params to optimize
        paramsList{jj}              =   ['p.' paramsList{jj}];
        lowbounds                   =   [lowbounds params.(module).(paramName).LowerBound];
        upbounds                    =   [upbounds params.(module).(paramName).UpperBound];

    catch
        error([pad('CRIT MODSTR',20,'left') ' : ' pad('setupOpti',20) ' | The optimized module or parameter name not exist in selected model structure, check params2opti in opti.json : ' mod_param])
    end
end

%% scaling of the bounds is moved to prepOpti
info.opti.params.names          = paramsList;
info.opti.params.uBounds        = upbounds;
% info.opti.params.uBoundsScaled  = upbounds  ./ pdefault;
info.opti.params.lBounds        = lowbounds;
% info.opti.params.lBoundsScaled  = lowbounds ./ pdefault;
info.opti.params.defaults       = pdefault;
% info.opti.params.defScalars     = pdefault  ./pdefault;


end