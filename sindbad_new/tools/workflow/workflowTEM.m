function workflowTEM(expConfigFile)
% %% workflow of the tem
% INPUT:    experiment configuration file OR info
%           + varargins (??)
%
% steps: 
%   1) setupTEM
%   2) prepTEM
%   3) runTEM
%   4) (postTEM)

% the experiment configuration file
if ~exist('expConfigFile','var')
    expConfigFile = '/Volumes/Kaam/Matlab_Works/sindbad/sindbad_new/settings/experiment_standard.json';
%     expConfigFile = '.\settings\experiment_standard.json';
end

% setup the TEM
info        = setupTEM(expConfigFile);

% prepare the TEM runs
[info, f]   = prepTEM(info);

% run the model

% post process the TEM outputs
