function [info,expConfigFile] = setupTEM(expConfigFile)
%% setups the experiment and TEM part of the info
% INPUT:    experiment configuration file OR an existing info
%           + additional command line informations what should be edited in the info
% OUTPUT:   info
% comment:  needs to be run where the repository is
%
% steps:
%   1) input = info or info.json file or experiment configuration file?
%     if configuration file:
%       - set info.experiment
%       - readConfigFiles
%   2) editINFOSettings
%   3) create the output folder structure
%   4) writeJsonFile of info
%   5) generate code and check model structure integrity
%   x) create helpers -> done in prepTEM as also forcing etc is needed
%   6) write the info structure in a mat file

%% get the sindbad root directory
info.experiment.sindbadroot         =   sindbadroot;

%% 1) check what is the input
if isstruct(expConfigFile)
    % is already a structure assume = info
    info	= expConfigFile;
    % store the old settings in a cell array called oldSettings ...
    if isfield(info.experiment,'oldSettings')
        k   = numel(info.experiment.oldSettings) + 1;
    else
        k	= 1;
    end
    info.experiment.oldSettings{k} = info.experiment;
    % stamp the experiment settings
    info = stampExperiment(info);
    % sujan hack to avoid trying to save the full info in the json file
    info.experiment.outputInfoFile='';
    
elseif exist([info.experiment.sindbadroot expConfigFile],'file')
    expConfigFile = [info.experiment.sindbadroot expConfigFile] ;
    %% 
    % note: this part can be outsorced to a initINFOFromConfig in case this
    % needs to be ran in other places 
%     expConfigFile                   =   getFullPath(expConfigFile);
    
    % is a file, assume a standard configuration file and read it
% sujan: making sure than sindbad root in not overwritten
    
    exp_json                 =   readJsonFile(expConfigFile);
    exp_json_fn              = fields(exp_json);
    for exp = 1:numel(exp_json_fn)
        info.experiment.(exp_json_fn{exp}) = exp_json.(exp_json_fn{exp});
    end
    % absolute paths of the config files
    info.experiment.configFiles     =   convertToFullPaths(info,info.experiment.configFiles);
        
    % stamp the experiment settings
    info                            =   stampExperiment(info);
    
    % read the TEM configurations
    info                            =   readConfigFiles(info,'tem',true);
    [info]  = createStatesInfo(info);
    
end

%% 4) write the info in a json file
end