function [info] = readConfiguration(info, whatWorkFlow, stopIfMissField)
% reads configuration files for TEM, postProcessing and puts them into the info
% INPUT:    info
%           whatworkflow:   tem OR opti OR postprocessing
% OUTPUT:   info

% steps:
%   1) decide which workflow + which fieldnames in info are added to (or
%   what are the config files?)
%   2) loop through the fieldnames, read the jsons + feed the info
%
%% check whether to immediately stop if there are missing fields...
if~exist('stopIfMissField','var'),stopIfMissField = true; end
isAllOK     = true;
missFields    = '';
%% 1) which workflow?
switch lower(whatWorkFlow)
    case 'tem' %creates all the substructures (fieldnames) of info.tem
        fldnmsINFO      = {'modelRun','modelStructure','spinup','forcing','constants','output', 'params'};%
        
    case 'postprocessing'
        fldnmsINFO = {};
        
    otherwise
        disp([pad('CRIT CONCEPT',20) ' : ' pad('readConfiguration',20) ' | only [modelRun,modelStructure,spinup,forcing,constants,output,params] are accepted'])
        disp([pad('CRIT CONCEPT',20) ' : ' pad('readConfiguration',20) ' | '  whatWorkFlow ' is not a known part of SINDBAD workflow (branch of opti)'])
end

%% 2) loop through the fieldnames

% go through the fldnms that are in the info.experiment.configFiles
% e.g. the reading of the info.experiment.configFiles.spinup -> info.tem.spinup

for ii = 1:numel(fldnmsINFO)
    % read the json configuration files
    try
        data_json    = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
    catch
        if ~strcmpi(fldnmsINFO{ii}, 'params')
        isAllOK     = false;
        end
        missFields  = [missFields ' ' fldnmsINFO{ii} ';'];
        
        disp([pad('CONFIG FIELMISS',20) ' : ' pad('readConfiguration',20) ' | configuration file for ' fldnmsINFO{ii} ' is missing in the experiment configuration'])
        continue
    end
    
    switch lower(fldnmsINFO{ii})
        case 'forcing'
             info.(whatWorkFlow).(fldnmsINFO{ii})    = data_json;
             % add all the forcing variables to forcingInput list
             info.(whatWorkFlow).model.variables.forcingInput = strcat('f.' ,fields(data_json.variables))';
             info.(whatWorkFlow).forcing.variableNames = fields(data_json.variables);
        case 'modelrun'
            % feed model run settings 
            % because "model" is set in 2 different instances (modelRun and
            % in modelStructure), we need to merge them one by one...
            loopIt = false;
            if isfield(info,'tem')
                if isfield(info.tem,'model')
                    loopIt = true;
                end
            end
            if loopIt
                for fn = fieldnames(data_json)'
                    info.(whatWorkFlow).model.(fn{1}) = mergeSubField(info.(whatWorkFlow).model,data_json,(fn{1}),'last');
                end
            else
                info.(whatWorkFlow).model    = data_json;
            end
        case 'modelstructure'
            % set the model structure and needed settings in general
            
            % feed the states
            state_fields      = fieldnames(data_json.states);
            for jj=1:numel(state_fields)
                info.(whatWorkFlow).model.variables.states.(state_fields{jj})  = data_json.states.(state_fields{jj});
            end
            
            % feed the modules/approaches
            module_fields     = fieldnames(data_json.modules);
            
            % loop over approaches
            paramInput={};
            for jj = 1 : size(module_fields, 1)
                approachName    = strsplit(data_json.modules.(module_fields{jj, 1}).apprName,'_');
                approachName    = approachName{1,2};
                
                info.(whatWorkFlow).model.modules.(module_fields{jj}).apprName    = approachName;
                info.(whatWorkFlow).model.modules.(module_fields{jj}).runFull     = data_json.modules.(module_fields{jj, 1}).runFull;
                info.(whatWorkFlow).model.modules.(module_fields{jj}).use4spinup     = data_json.modules.(module_fields{jj, 1}).use4spinup;
                
                % read parameter information of the approaches
                file_json   = convertToFullPaths(info,['model' '/' 'modules' '/' module_fields{jj} '/' module_fields{jj} '_' approachName  '/' module_fields{jj} '_' approachName '.json']);
                if exist(file_json,'file')
                    param_json    = readJsonFile(file_json);
                    paramName     = fieldnames(param_json.params);
                    %sujan remove try catch after all jsons have been
                    %modified
                    try
                        info.tem.model.modules.(module_fields{jj}).devStage = param_json.devStage;
                    catch 
                    end
                    % loop over the parameter of the approach & get the default value
                    for pp=1:numel(paramName)
                        info.tem.params.(module_fields{jj}).(paramName{pp}) = param_json.params.(paramName{pp}).Default;
                        info.tem.allparams.(module_fields{jj}).(paramName{pp}) = param_json.params.(paramName{pp});
                        paramInput = [paramInput ['p.', module_fields{jj}, '.', paramName{pp}]];
                    end
                    
                    % write in the info that default parameter values are used
                    
                else
                    disp([pad('WARN PARAM FILEMISS',20) ' : ' pad('readConfiguration',20) ' | Parameter config (json) missing | module : ' pad(module_fields{jj},20) ' | approach: ' approachName]);
                end
            end
            
            % feed list of params
            info.(whatWorkFlow).model.variables.paramInput = paramInput;
            % feed the paths
            info.(whatWorkFlow).model.paths = mergeSubField(info.(whatWorkFlow).model,data_json,'paths','last');
            
        case 'params'
            paramJson = data_json.parameter;
            % loop over model parameter
                paraDef     = [];
                paraNew     = [];
            for pp=1:numel(info.tem.model.variables.paramInput)
                paraName    = info.tem.model.variables.paramInput{pp};
                tmp         = strsplit(paraName,'.');
                % look if an alternative value is provided in the json file
                if isfield(paramJson, tmp(2))
                    moduleJson = paramJson.(tmp{2});
                    if isfield(moduleJson, tmp(3)) && ~isempty(moduleJson.(tmp{3}))
                        % values or scalars in the json?
                        if data_json.type == 'value'
                            info.tem.params.(tmp{2}).(tmp{3}) = moduleJson.(tmp{3})(1); %set 1st value - DOES NOT ACCOUNT FOR SPATIAL VARIATION!
                        elseif data_json.type == 'scalar'
                            info.tem.params.(tmp{2}).(tmp{3}) = info.tem.params.(tmp{2}).(tmp{3}) .* moduleJson.(tmp{3});
                        else
                            disp([pad('WARN PARAM TYPE',20) ' : ' pad('readConfiguration',20) ' | invalid type in parameter json file! needs to be value or scalar. parameter ' tmp{2} '.' tmp{3} ' is not changed. '])
                        end
                        paraNew = [paraNew tmp{2} '.' tmp{3} ', '];
                    else
                        paraDef = [paraDef tmp{2} '.' tmp{3} ', '];
                    end
                else
                    paraDef = [paraDef tmp{2} '.' tmp{3} ', '];
                end
            end
            
            % write in the info that default parameter values are used
             
            % display, which parameters are changed and for which the
            % default value is used
            disp([pad(' ',20) ' : ' pad('readConfiguration',20) ' | default parameter values are used for: ' paraDef])
            disp([pad(' ',20) ' : ' pad('readConfiguration',20) ' | parameter values from ' info.experiment.configFiles.(fldnmsINFO{ii}) ' are used for: '])
            disp([pad(' ',20) ' : ' pad('readConfiguration',20) ' | ' paraNew])

            
        case 'output'
            % set variables for output and storage
            info.(whatWorkFlow).model.variables.to          = data_json.variables.to; %so far only includes the variables that need to be written
            info.(whatWorkFlow).model.variables.to.store    = info.(whatWorkFlow).model.variables.to.store;
            info.(whatWorkFlow).model.output.dataFormat     = data_json.dataFormat;
            
        otherwise % these include 'spinup' and all other cases
            info.(whatWorkFlow).(fldnmsINFO{ii})    = data_json;
    end
end

%--> sujan: moved variables to sum to a suitable place in info
if isfield(info.tem.model, 'varsToSum') %%TINA HACK
info.tem.model.variables.to.sum                             = info.tem.model.varsToSum;
info.tem.model                                              = rmfield(info.tem.model,'varsToSum');
else
    info.tem.model.variables.to.sum  = struct;
end

if stopIfMissField && isAllOK == false
    error([pad('CRIT FIELDMISS',20) ' : ' pad('readConfiguration',20) ' | necessary fields are missing in configuration files : ' missFields])
end



end
