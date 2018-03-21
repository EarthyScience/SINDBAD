function workflowTEM(expConfigFile)
% workflow of the tem

% the experiment configuratio file
if ~exist('expConfigFile','var')
    expConfigFile = '.\settings\experiment_standard.json';
end

% setup the TEM
info = setupTEM(expConfigFile);

% prepare the TEM runs

% run the model

% post process the TEM outputs
