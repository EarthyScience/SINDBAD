function [info] = readConfigFiles(info, whatWorkFlow, stopIfMissField)
%% reads configuration files for TEM, opti or postProcessing and puts them into the info
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
missFields	= '';
%% 1) which workflow?
switch lower(whatWorkFlow)
    case 'tem' %creates all the substructures (fieldnames) of info.tem
        fldnmsINFO      = {'modelRun','modelStructure','spinup','forcing','constants','output'};%'params'
        
    case 'opti' %creates all the substructures (fieldnames) of info.opti
        fldnmsINFO = {}; %{'constraints','costFun','method','params', 'checks'}: %
        
    case 'postprocessing'
        fldnmsINFO = {};
        
    otherwise
        error(['ERR : readConfigFiles : not a known sindbad workflow : ' whatWorkFlow])
end

%% 2) loop through the fieldnames

% unique name for the generated code files according to
% experiment name and to runDate.
tmpStrName	= [info.experiment.name '_' info.experiment.domain '_' datestr(info.experiment.runDate,30)];
tmpStrName  = strrep(strrep(tmpStrName,' ','_'),'-','_');


% go through the fldnms that are in the info.experiment.configFiles
% e.g. the reading of the info.experiment.configFiles.spinup -> info.tem.spinup

for ii = 1:numel(fldnmsINFO)
    % read the json configuration files
    try
        data_json	= readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
    catch
        isAllOK     = false;
        missFields  = [missFields ' ' fldnmsINFO{ii} ';'];
        disp(['MSG: readConfigFiles : is not in a configuration file! issue reading configuration file for : ' whatWorkFlow ' : ' fldnmsINFO{ii} ' : ' info.experiment.configFiles.(fldnmsINFO{ii})])
        continue
    end
    
    switch lower(fldnmsINFO{ii})
        case 'modelrun'
            % feed model run settings 
            info.(whatWorkFlow).model	= data_json;
            % feed that into the structure
            info.(whatWorkFlow).model.paths.genCode.coreTEM         = ['genCore_' tmpStrName '.m'];
            info.(whatWorkFlow).model.paths.genCode.preCompOnce     = ['genPrecOnce_' tmpStrName '.m'];
            info.(whatWorkFlow).spinup.paths.genCode.coreTEM        = ['genCoreSpinup_' tmpStrName '.m'];
            info.(whatWorkFlow).spinup.paths.genCode.preCompOnce	= ['genPrecOnceSpinup_' tmpStrName '.m'];
            
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
            for jj = 1 : size(module_fields, 1)
                approachName    = strsplit(data_json.modules.(module_fields{jj, 1}).ApproachName{1},'_');
                approachName    = approachName{1,2};
                
                info.(whatWorkFlow).model.modules.(module_fields{jj}).apprName    = approachName;
                info.(whatWorkFlow).model.modules.(module_fields{jj}).runFull     = data_json.modules.(module_fields{jj, 1}).runFull;
                
                % read parameter information of the approaches
                file_json   = convertToFullPaths(['./model/modules/' module_fields{jj} '/' module_fields{jj} '_' approachName  '/' module_fields{jj} '_' approachName '.json']);
                if exist(file_json,'file')
                    param_json    = readJsonFile(file_json);
                    paramName     = fieldnames(param_json.params);
                    % loop over the parameter of the approach & get the default value
                    for pp=1:numel(paramName)
                        info.tem.params.(module_fields{jj}).(paramName{pp}) = param_json.params.(paramName{pp}).Default;
                    end
                else
                    disp(['MSG: readConfigFiles : no parameter config file (json) existing for approach: ' approachName]);
                    isAllOK     = false;
                    missFields  = [missFields ' ' fldnmsINFO{ii} ' for ' approachName ];
                end
            end
            
        case 'output'
            % set variables for output and storage
            info.(whatWorkFlow).model.variables.to          = data_json.variables.to; %so far only includes the variables that need to be written
            info.(whatWorkFlow).model.variables.to.store	= info.(whatWorkFlow).model.variables.to.write;
            
        case 'spinup'
            % spin upt settings and names
            info.(whatWorkFlow).(fldnmsINFO{ii})                    = data_json;
            info.(whatWorkFlow).spinup.paths.genCode.coreTEM        = ['genCoreSpinup_' tmpStrName '.m'];
            info.(whatWorkFlow).spinup.paths.genCode.preCompOnce    = ['genPrecOnceSpinup_' tmpStrName '.m'];
            
        otherwise
            info.(whatWorkFlow).(fldnmsINFO{ii}) = data_json;
    end
end

if stopIfMissField && isAllOK == false
    error(['MSG: readConfigFiles : missing necessary fields in configuration files : ' missFields])
end

% %% USEFUL FOR OPTIMIZATION CASE:
% %read parameter info of the approaches
% param_json    = readJsonFile(['./model/modules/' char(modules{jj}) '/' char(data_json{jj}.ApproachName) '/' char(data_json{jj}.ApproachName) '.json' ]);
% paramName     = param_json.Params.VariableName;
% % loop over the parameter of the approach & get the
% % default value
% for pp=1:numel(paramName)
%     info.tem.params.(modules{jj}).(paramName{pp}) = param_json.Params.Default(pp);
%
%
%     param_info    = fieldnames(param_json.Params);
%     % loop over the parameter characteristics provided in the json
%     for ppi = 1:numel(param_info)
%         info.opti.params.(modules{jj}).(paramName{pp}).(param_info{ppi}) = param_json.Params.(param_info{ppi})(pp);
%     end
% end


end