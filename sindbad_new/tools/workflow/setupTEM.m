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
if isstruct(expConfigFile)==1
    info        = expConfigFile;
elseif strcmp(expConfigFile(end-10:end),'_info.json')==1
    info        = readJsonFile(expConfigFile);
else
%% 2) read the experiment configuration file(s)
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
    info    = readConfigFiles(info,'tem');
    
    % % read the optimization (if it exists) ????
    % if isfield(info.experiment.configFiles,'opti')
    %     if exist(info.experiment.configFiles.opti,'file')
    %         info = readConfigFiles(info,'opti');
    %     end
    % end
    
end

%% 3) edit the TEM (optional changing of fieldvalues in the info strucure)
        % replace 'apprName' with 'info.tem.model.modules.Qsnw.apprName' and remove the 'Fantasy','Einhorn' pair to check functionality
%info        = editTEMSettings(info, 'berg', 1.5, 'ETsup', 0.01, 'apprName', 'Bla', 'Fantasy', 'Einhorn');


%% 4) genCode
%% 5) write the info in a json file
[pth,~,~]   = fileparts(expConfigFile);
writeJsonFile(pth, [char(expSettings.name) '_info.json'], info);

end