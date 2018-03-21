function [info] = readConfigFiles(info,whatWorkFlow)
switch lower(whatWorkFlow)
    case 'tem'
        fldnms = {'spinup','forcing','constants','parameters','modelRun','modelStructure','output'};
    case 'opti'
    case 'postProcessing'
    otherwise
        error(['ERR : readConfigFiles : not a known sindbad workflow : ' whatWorkFlow])
end

% go through the fldnms that are in the info.experiment.configFiles 
% e.g.:
% the reading of the info.experiment.configFiles.spinup -> info.tem.spinup

for i = 1:numel(fldnms)
    % feed the info with 
    info.(whatWorkFlow).(fldnms{i}) = jsondecode(fileread(info.experiment.configFiles.(fldnms{i})));
end
end