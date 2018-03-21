function info = setupTEM(expConfigFile)
% needs to be run where the repository is 

% read the experiment configuration file
expSettings	= jsondecode(fileread(expConfigFile));

% add additional information
[expSettings.usedVersion,~] = system('git rev-parse HEAD');
expSettings.userName        = getenv('username');
expSettings.runDate         = datestr(now);

% feed the info
info.experiment = expSettings;

% read the configuration files
info = readConfigFiles(info,'tem');

% read the optimization (if it exists)
if isfield(info.experiment.configFiles,'opti')
    if exist(info.experiment.configFiles.opti,'file')
        info = readConfigFiles(info,'opti');
    end
end


% 


end