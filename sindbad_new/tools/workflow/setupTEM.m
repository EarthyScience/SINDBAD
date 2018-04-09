function info = setupTEM(expConfigFile,varargin)
%% setups the experiment and TEM part of the info
% INPUT:    experiment configuration file OR an existing info
%           + additional command line informations what should be edited in the info
% OUTPUT:   info
% comment:  needs to be run where the repository is
%
% steps:
%   1) input = info or info.json file or experiment configuration file?
%   2) if configuration file:
%       - set info.experiment
%       - readConfigFiles
%   3) editTEMSettings
%   4) writeJsonFile of info
%

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
elseif exist(expConfigFile,'file')
    % is a file, assume a standard configuration file and read it
    info.experiment = readJsonFile(expConfigFile);
    % read the TEM configurations
    info    = readConfigFiles(info,'tem');
    % read the optimization configurations (if it exists)
    if isfield(info.experiment.configFiles,'opti')
        if exist(info.experiment.configFiles.opti,'file')
            info = readConfigFiles(info,'opti');
        end
    end
end
%% 2) add additional information (stamp the experiment settings)
info = stampExperiment(info);
    
%% 3) edit the settings of the TEM based on the function inputs
info = editTEMSettings(info,varargin{:});

%% 4) write the info in a json file
if isfield(info.experiment,'outputInfoFile')
    [pth,name,ext]   = fileparts(info.experiment.outputInfoFile);
    if~exist(pth,'dir'),mkdir(pth);end
    writeJsonFile(pth, [name '.' ext], info);
else
    disp('MSG : setupTEM : no "outputInfoFile" was provided : the info structure will not be saved')
end

end