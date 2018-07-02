function [f,fe,fx,s,d,p,precOnceData,sSU,dSU,info] = workflowTEM(expConfigFile,varargin)
% function info = workflowTEM(expConfigFile,varargin)
% workflow of the tem
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

%% set up the optimization if it's on 
if info.tem.model.flags.runOpti
    [info, obs] =  prepOpti(info);
end

%% set up the model structure
[info] = setupCode(info);


%% 2) prepare the TEM runs
[f,fe,fx,s,d,info]   =  prepTEM(info);


%% 3) Forward run the model
if info.tem.model.flags.forwardRun && ~info.tem.model.flags.runOpti
    p       =   info.tem.params;
    [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,p);
end
% return
%% Optimize the model
if info.tem.model.flags.runOpti
    optimizerFunName = ['optimizeTEM_' info.opti.algorithm.funName];
    if ~exist(optimizerFunName)
        optimizerFunName = 'optimizeTEM';
    end
    
    optimizerFunHandle = str2func(optimizerFunName);
    [pScalesS]   = feval(optimizerFunHandle,f,obs,info);
    pScales = pScalesS.x;
    %      [pScales]   = optimizeTEM(f,obs,info);
    p=info.tem.params;
    for i = 1:numel(info.opti.params.names)
        eval([info.opti.params.names{i} ' = info.opti.params.defaults(i) .* pScales(i);'])
    end
            [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,p);
end

% [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,'p',p);
%
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f);


%% 4) post process the TEM outputs
% save the info as mat file
save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate '_info.mat'], 'info', '-v7.3')

% save the f as mat file
save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate  '_f.mat'], 'f', '-v7.3')

