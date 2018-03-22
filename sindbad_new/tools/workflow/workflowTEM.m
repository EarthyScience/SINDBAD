function workflowTEM(expConfigFile)
%% workflow of the tem
% INPUT:    experiment configuration file OR info
%
% steps: 
%   1) setupTEM
%   2) prepTEM
%   3) runTEM
%   4) (postTEM)

% the experiment configuration file
if ~exist('expConfigFile','var')
    expConfigFile = '.\settings\experiment_standard.json';
end

% setup the TEM
info = setupTEM(expConfigFile);

% prepare the TEM runs

% run the model

% post process the TEM outputs
