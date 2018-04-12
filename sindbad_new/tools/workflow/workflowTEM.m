function info = workflowTEM(expConfigFile,varargin)
% %% workflow of the tem
% INPUT:    experiment configuration file OR info
%           + varargins (??)
% OUTPUT:   info.m
%           f.m
%
% steps: 
%   1) setupTEM
%   2) prepTEM
%   3) runTEM
%   4) (postTEM)

% the experiment configuration file
if ~exist('expConfigFile','var')
    error('ERR : workflowTEM : configuration file or info structure is a required input')
end

%% 1) setup the TEM
info        = setupTEM(expConfigFile,varargin{:});

%% 2) prepare the TEM runs
[info, f]   = prepTEM(info);


%% 3) run the model

%% 4) post process the TEM outputs
% save the info as mat file
save([info.experiment.outputDirPath info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd') '_info.mat'], 'info', '-v7.3')

% save the f as mat file
save([info.experiment.outputDirPath info.experiment.name '_' datestr(info.experiment.runDate,'yyyy-mm-dd')  '_f.mat'], 'f', '-v7.3')

