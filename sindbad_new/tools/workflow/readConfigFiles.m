function [info] = readConfigFiles(info,whatWorkFlow)
%% reads configuration files for tem, opti or postProcessing and puts them into info
switch lower(whatWorkFlow)
    case 'tem' %creates all the substructures (fieldnames) of info.tem
        %fldnmsCONFIG    = 
        fldnmsINFO      = {'modelStructure','spinup','forcing','constants','params'};
        
    case 'opti' %creates all the substructures (fieldnames) of info.opti
        fldnmsINFO = {}; %{'constraints','costFun','method','params', 'checks'}: %
        
    case 'postprocessing'
        fldnmsINFO = {};
        
    otherwise
        error(['ERR : readConfigFiles : not a known sindbad workflow : ' whatWorkFlow])
end

%% loop through the fieldnames
% go through the fldnms that are in the info.experiment.configFiles 
% e.g.:
% the reading of the info.experiment.configFiles.spinup -> info.tem.spinup

for ii = 1:numel(fldnmsINFO)
    % feed the info with 
    
    switch lower(fldnmsINFO{ii})
        case 'modelstructure'
            try 
                data_json = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
                modules = fieldnames(data_json);
                data_json = struct2cell(data_json);
                            
                for jj = 1 : size(data_json, 1)
                    
                    approachName = strsplit(data_json{jj, 1}.ApproachName{1},'_');
                    approachName = approachName{1,2};
                    
                    info.(whatWorkFlow).model.modules.(modules{jj}).apprName = approachName;
                    info.(whatWorkFlow).model.modules.(modules{jj}).runFull = data_json{jj, 1}.runFull;
                end    
            catch
                disp([fldnmsINFO{ii} 'is not in a configuration file! or something else went wrong ;o) '])
            end
        otherwise
            try 
                info.(whatWorkFlow).(fldnmsINFO{ii}) = readJsonFile(info.experiment.configFiles.(fldnmsINFO{ii}));
            catch
                 disp([fldnmsINFO{ii} 'is not in a configuration file!'])
           end
    end
end

end