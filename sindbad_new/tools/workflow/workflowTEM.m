function info = workflowTEM(expConfigFile)
% %% workflow of the tem
% INPUT:    experiment configuration file OR info
%           + varargins (??)
% OUTPUT:   info.m
%           f.m
%
% steps: 
%   1) setupTEM
%   ?1.5) editTEMSettings?
%   2) prepTEM
%   3) runTEM
%   4) (postTEM)

% the experiment configuration file
if ~exist('expConfigFile','var')
    expConfigFile = '/Volumes/Kaam/Matlab_Works/sindbad/sindbad_new/settings/experiment_BergBasic.json';
%     expConfigFile = '.\settings\experiment_standard.json';
end

%% 1) setup the TEM
info        = setupTEM(expConfigFile);

%% 1.5) edit the TEM (optional changing of fieldvalues in the info strucure)
        % replace 'apprName' with 'info.tem.model.modules.Qsnw.apprName' and remove the 'Fantasy','Einhorn' pair to
        % check functionality
info        = editTEMSettings(info, 'berg', 1.5, 'ETsup', 0.01, 'apprName', 'Bla', 'Fantasy', 'Einhorn');

%% 2) prepare the TEM runs
[info, f]   = prepTEM(info);

%% 3) run the model

%% 4) post process the TEM outputs
% save the info as mat file
save([info.experiment.outputDirPath info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd') '_info.m'], 'info', '-v7.3')

% save the f as mat file
save([info.experiment.outputDirPath info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd')  '_f.m'], 'f', '-v7.3')

