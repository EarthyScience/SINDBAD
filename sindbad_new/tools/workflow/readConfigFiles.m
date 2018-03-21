function [info] = readConfigFiles(info,whatWorkFlow)
%% reads configuration files for tem, opti or postProcessing and puts them into info
switch lower(whatWorkFlow)
    case 'tem' %creates all the substructures (fieldnames) of info.tem
        fldnmsCONFIG    = 
        fldnmsINFO      = {'spinup','forcing','constants','params'};%,'modelRun'=model,'modelStructure'=model.approaches,'output'=model.variables.to};
        
    case 'opti' %creates all the substructures (fieldnames) of info.opti
        fldnmsINFO = {}; %{'constraints','costFun','method','params', 'checks'}: %
        
    case 'postProcessing'
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
    try 
        info.(whatWorkFlow).(fldnmsINFO{ii}) = readJsonFile(info.experiment.configFiles.(fldnmsCONFIG{ii}));
    catch
        mmsg([fldnmsINFO{ii} 'is not in a configuration file!'])
    end
end

end