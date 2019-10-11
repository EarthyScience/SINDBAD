function [info,expConfigFile] = setupTEM(expConfigFile)
% setups the experiment part of the info and date arrays
%
% Requires:
%	- a configuration file for an experiment or
%	- an info structure
%
% Purposes:
%   - setups the the experiment and TEM part of the info 
%   - based on the experiment configuration files or an existing info
%   - reads configuration files 
%
% steps:
%   1) get sindbad root
%   2) input = info or experiment configuration file?
%     if configuration file:
%       - set info.experiment
%       - readConfigFiles
%   3) add date helpers
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
%   - 1.1 on 15.08.2018 



%% 1) get the sindbad root directory
info.experiment.sindbadroot         =   sindbadroot;

%% 2) check what is the input
if isstruct(expConfigFile)
    disp(pad('-',200,'both','-'))
    disp([pad('MOD EXPERIMENT',20) ' : ' pad('setupTEM',20) ' | Running SINDBAD using info structure'])
    disp(pad('-',200,'both','-'))
    
    % is already a structure assume = info
    info            = expConfigFile;
    
    % store the old settings in a cell array called oldSettings ...
    if isfield(info.experiment,'oldSettings')
        k   = numel(info.experiment.oldSettings) + 1;
    else
        k	= 1;
    end
    info.experiment.oldSettings{k} = info.experiment;
    
    % stamp the experiment settings
    info = setExperimentInfo(info);
    % sujan hack to avoid trying to save the full info in the json file
    info.experiment.outputInfoFile='';
    % function handles should be removed for saving infoLite.. 
    
elseif exist([info.experiment.sindbadroot expConfigFile],'file')
    expConfigFile = [info.experiment.sindbadroot expConfigFile] ;
    %%
    % note: this part can be outsorced to a initINFOFromConfig in case this
    % needs to be ran in other places
    %     expConfigFile                   =   getFullPath(expConfigFile);
    
    % is a file, assume a standard configuration file and read it
    % sujan: making sure than sindbad root in not overwritten
    disp(pad('-',200,'both','-'))
    disp([pad('MOD EXPERIMENT',20) ' : ' pad('setupTEM',20) ' | Running SINDBAD using an experiment configuration file: ' expConfigFile])
    disp(pad('-',200,'both','-'))
    
    exp_json                    =   readJsonFile(expConfigFile);
    exp_json_fn                 =  fields(exp_json);
    for exp = 1:numel(exp_json_fn)
        info.experiment.(exp_json_fn{exp}) = exp_json.(exp_json_fn{exp});
    end
    
    % absolute paths of the config files
    info.experiment.configFiles     =   convertToFullPaths(info,info.experiment.configFiles);
    
    % stamp the experiment settings
    info                            =   setExperimentInfo(info);
    
    % read the TEM configurations
    info                            =   readConfiguration(info,'tem',true);
    [info]                          =   setupStateInfo(info);
    
else
    disp(pad('-',200,'both','-'))
    error([pad('MOD EXPERIMENT',20) ' : ' pad('setupTEM',20) ' | No valid SINDBAD info or an experiment configuration file is provided. Make sure that ' expConfigFile ' exists'])
    disp(pad('-',200,'both','-'))
    
    
end

%% add date helpers
info.tem.helpers.dates.day   = createDateVector(info.tem.model.time.sDate, info.tem.model.time.eDate, 'd');
info.tem.helpers.dates.month = createDateVector(info.tem.model.time.sDate, info.tem.model.time.eDate, 'm');

end