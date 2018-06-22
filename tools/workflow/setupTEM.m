function info = setupTEM(expConfigFile,varargin)
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

%% 1) check what is the input
if isstruct(expConfigFile) == 1
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
    
elseif exist(expConfigFile,'file')
    %% 
    % note: this part can be outsorced to a initINFOFromConfig in case this
    % needs to be ran in other places 
    
    % is a file, assume a standard configuration file and read it
    info.experiment                 =   readJsonFile(expConfigFile);
    % absolute paths of the config files
    info.experiment.configFiles     =   convertToFullPaths(info.experiment.configFiles);
        
    % stamp the experiment settings
    info    = stampExperiment(info);
    
    % read the TEM configurations
    info    = readConfigFiles(info,'tem',true);
    
    % read the OPTI configurations (if it exists)
    if isfield(info.experiment.configFiles,'opti')
        if ~isempty(info.experiment.configFiles.opti)
            info = readConfigFiles(info,'opti',false);
        end
    end
    
    
    [info]  = createStatesInfo(info);
    
end

%% 2) edit the settings of the TEM based on the function inputs
[info, tree]	=   editINFOSettings(info,varargin{:});
[info]          =   adjustInfo(info, tree);

%% 3) paths & output folder structure
% set the paths and output folder structure
[info]  = setExperimentPaths(info);

% create the output folder structure
if ~exist(info.experiment.outputDirPath, 'dir'), mkdir(info.experiment.outputDirPath); end
% copy the settings there (assuming they are in the same folder as the
% expConfigFile
[pth,~,~] = fileparts(expConfigFile)
copyfile(pth,[info.experiment.outputDirPath filesep 'settings' filesep])

%% 4) write the info in a json file
if isfield(info.experiment,'outputInfoFile')
    if ~isempty(info.experiment.outputInfoFile)
        [pth,name,ext]          =   fileparts(info.experiment.outputInfoFile);
        if~exist(pth,'dir'),mkdir(pth);end
        savejsonJL('',info,info.experiment.outputInfoFile);
%sujan        writeJsonFile(pth, [name ext], info);
    end
else
    disp('MSG : setupTEM : no "outputInfoFile" was provided : the info structure will not be saved')
end

%% 5) generate code and check model structure integrity
[info] = setupCode(info);

%% setup the information of states to info.tem.model.variables.states.
% if isfield(info.tem.model.variables.states,'input')
%     [info] = createStatesInfo(info);
% end;
%%

% info.runPrecOnceTEM

%% 6) write the info structure in a mat file ?

end