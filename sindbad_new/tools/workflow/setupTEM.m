function info = setupTEM(expConfigFile,varargin)
% needs to be run where the repository is 

% read the experiment configuration file
expSettings = readJsonFile(expConfigFile);

% add additional information
[expSettings.usedVersion,~] = system('git rev-parse HEAD');
expSettings.userName        = getenv('username');
expSettings.runDate         = datestr(now);

% feed the info
info.experiment = expSettings;

% create the output path if it not yet exists
if ~exist(info.experiment.outputDirPath, 'dir'), mkdir(info.experiment.outputDirPath);end

% read the configuration files
info = readConfigFiles(info,'tem');

% read the optimization (if it exists)
if isfield(info.experiment.configFiles,'opti')
    if exist(info.experiment.configFiles.opti,'file')
        info = readConfigFiles(info,'opti');
    end
end


% edit the settings of the tem based on the function inputs
% info = editTEMSettings(info,varargin{:});

% write the info in a json file
[pth,~,~] = fileparts(expConfigFile);
writeJsonFile(pth, 'info.json', info);


end