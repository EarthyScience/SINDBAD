function [info] = readConfigFiles(info, whatWorkFlow)
%% reads configuration files for TEM, opti or postProcessing and puts them into the info
% INPUT:    info
%           whatworkflow:   tem OR opti OR postprocessing
% OUTPUT:   info
%
% steps:
%   1) decide which workflow + which fieldnames in info are added to (or
%   what are the config files?)
%   2) loop through the fieldnames, read the jsons + feed the info
%

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
% go through the fldnms that are in the info.experiment.configFiles 
% e.g. the reading of the info.experiment.configFiles.spinup -> info.tem.spinup

for ii = 1:numel(fldnmsINFO)
    switch lower(fldnmsINFO{ii})
        case 'modelrun'
            try 
                data_json   = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));                
                info.(whatWorkFlow).model = data_json; 
                info.(whatWorkFlow).model.paths.genCode.coreTEM        = ['genCore_' info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd') '.m'];
                info.(whatWorkFlow).model.paths.genCode.preCompOnce    = ['genPrecOnce_' info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd') '.m'];
            catch
                disp([fldnmsINFO{ii} ' is not in a configuration file! or something else went wrong ;o) modelrun'])
            end
            
        case 'modelstructure'
            try 
                data_json   = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
                
                % feed the states
                state_fields      = fieldnames(data_json.states); 
                for jj=1:numel(state_fields)
                    info.(whatWorkFlow).model.variables.states.(state_fields{jj})  = data_json.states.(state_fields{jj});
                end
                
                % feed the modules/approaches
                module_fields     = fieldnames(data_json.modules);
                %data_json   = struct2cell(data_json); needed?
                
                % loop over approaches
                for jj = 1 : size(module_fields, 1)                    
                    approachName    = strsplit(data_json.modules.(module_fields{jj, 1}).ApproachName{1},'_');
                    approachName    = approachName{1,2};
                    
                    info.(whatWorkFlow).model.modules.(module_fields{jj}).apprName    = approachName;
                    info.(whatWorkFlow).model.modules.(module_fields{jj}).runFull     = data_json.modules.(module_fields{jj, 1}).runFull;
                    
                    % read parameter information of the approaches
                    file_json   = ['./model/modules/' module_fields{jj} '/' module_fields{jj} '_' approachName  '/' module_fields{jj} '_' approachName '.json'];
                    if exist(file_json,'file')
                        param_json    = readJsonFile(file_json);                  
                        paramName     = fieldnames(param_json.params);
                        % loop over the parameter of the approach & get the default value
                        for pp=1:numel(paramName)
                            info.tem.params.(module_fields{jj}).(paramName{pp}) = param_json.params.(paramName{pp}).Default;
                        end
                    else
                        disp(['no parameter config file (json) existing for approach: ' approachName]);
                    end
                end 
                
            catch
                disp([fldnmsINFO{ii} ' is not in a configuration file! or something else went wrong ;o) modelstructure'])
            end
            
         case 'output'
            try 
                data_json   = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));                
                info.(whatWorkFlow).model = data_json; %so far only includes the variables that need to be written
                info.(whatWorkFlow).model.variables.to.store = info.(whatWorkFlow).model.variables.to.write; 
            catch
                disp([fldnmsINFO{ii} ' is not in a configuration file! or something else went wrong ;o) output'])
            end
            
        otherwise
            try 
                info.(whatWorkFlow).(fldnmsINFO{ii}) = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
            catch
                 disp([fldnmsINFO{ii} ' is not in a configuration file!'])
           end
    end
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