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
%   3) writeJsonFile of info
%   4) generate code and check model structure integrity
%   5) create helpers
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
elseif exist(expConfigFile,'file')
    %%
    % note: this part can be outsorced to a initINFOFromConfig in case this
    % needs to be ran in other places

    % is a file, assume a standard configuration file and read it
    info.experiment = readJsonFile(expConfigFile);
    % convert info.experiment.configFiles paths to absolute paths
    info.experiment.configFiles     = convertToFullPaths(info.experiment.configFiles);
    info.experiment.outputInfoFile	= convertToFullPaths(info.experiment.outputInfoFile);
    info.experiment.outputDirPath	  = convertToFullPaths(info.experiment.outputDirPath);
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
	% set the generated code filenames into the info
	info 	= setGenCodePaths(info);
    % convert paths in info to absolute paths
    info.tem.model.paths	= convertToFullPaths(info.tem.model.paths);
    info.tem.spinup.paths = convertToFullPaths(info.tem.spinup.paths);

end

%% 2) edit the settings of the TEM based on the function inputs
%[info, ~]       = editINFOSettings(info,varargin{:});
[info, tree]	= editINFOSettings(info,varargin{:}) ;%'Orth2013'
% check the edited changes + change dependent fields (e.g. parameter if the approach has changed)
[info]      = adjustInfo(info, tree);

%% 3) write the info in a json file
if isfield(info.experiment,'outputInfoFile')
    if ~isempty(info.experiment.outputInfoFile)
        [pth,name,ext]   = fileparts(info.experiment.outputInfoFile);
        if~exist(pth,'dir'),mkdir(pth);end
        writeJsonFile(pth, [name ext], info);
    end
else
    disp('MSG : setupTEM : no "outputInfoFile" was provided : the info structure will not be saved')
end

%% 4) generate code and check model structure integrity
info = setupCode(info);


%% 6) write the info structure in a mat file

end
