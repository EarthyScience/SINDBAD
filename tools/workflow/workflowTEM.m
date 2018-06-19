function [f,fe,fx,s,d,p,precOnceData,sSU,dSU,info] = workflowTEM(expConfigFile,varargin)
% function info = workflowTEM(expConfigFile,varargin)

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

%%
if ~exist('expConfigFile','var')
    error('ERR : workflowTEM : configuration file or info structure is a required input')
end

%% 1) setup the TEM
info                 =  setupTEM(expConfigFile,varargin{:});
    
%% 2) prepare the TEM runs
[f,fe,fx,s,d,info]   =  prepTEM(info);


% [info, obs]          =  prepOpti(info);


%% 3) run the model
p=info.tem.params;

[f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,'p',p);

[f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f);
 

%% 4) post process the TEM outputs
% save the info as mat file
save([info.experiment.outputDirPath info.experiment.name '_' info.experiment.runDate '_info.mat'], 'info', '-v7.3')

% save the f as mat file
save([info.experiment.outputDirPath info.experiment.name '_' info.experiment.runDate  '_f.mat'], 'f', '-v7.3')

