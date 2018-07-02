function [f,fe,fx,s,d,p,precOnceData,sSU,dSU,info] = workflowExperiment(expConfigFile,varargin)
% Runs a SINDBAD model experiment with either a given experimental config or info
%
% Requires:
%	- a configuration file for a n experiment or
%	- an info structure
%
% Purposes:
%   - Runs the experiment based on the configuration files or info
%
% Conventions:
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%
% Versions:
%   - 1.0 on 01.07.2018

%% create a temporary log file
diary('tmpLogSINDBADrun____.txt')
disp('--------------------------------------')
disp('START: Log of SINDBAD model experiment')
disp('--------------------------------------')
%% check if the experiment configuration has been passed. Stop, if not.
if ~exist('expConfigFile','var')
    error('CRIT : runExperiment : Cannot run experiment without configuration file: expConfigFile[.json] or SINDBAD info')
end

%% setup the TEM
disp('------------------------------')
disp('Set up the TEM of SINDBAD')
disp('------------------------------')
[info, expConfigFile]                       =   setupTEM(expConfigFile);


%% 4) write the info in a json file
%% setup the optimization if it's on
if info.tem.model.flags.runOpti
    disp('----------------------------------')
    disp('Set up the optimization of SINDBAD')
    disp('----------------------------------')
    [info]                                  =   readOpti(info);
    [info]                                  =   editTEMInfo(info,varargin{:});
    infoLite                                =   info;
    [info, obs]                             =   prepOpti(info);
else
    [info]                                  =   editTEMInfo(info,varargin{:});
    infoLite                                =   info;
end

%% setup the model structure
disp('----------------------------------------------------------')
disp('Setup the model structure and generate the code of SINDBAD')
disp('----------------------------------------------------------')
[info]                                      =   setupCode(info);

%% prepare the SINDBAD objects and structures
disp('--------------------------------------------')
disp('Prepare the objects and structure of SINDBAD')
disp('--------------------------------------------')
[f,fe,fx,s,d,info]                          =   prepTEM(info);

%% Forward run the model when optimization is off
if info.tem.model.flags.forwardRun && ~info.tem.model.flags.runOpti
    disp('-------------------------------------------------')
    disp('Forward run SINDBAD model with default parameters')
    disp('-------------------------------------------------')
    p                                       =   info.tem.params;
    [f,fe,fx,s,d,p,precOnceData,sSU,dSU]    =   runTEM(info,f,p);
end

%% Optimize the model and then do the forward run using optimized parameter when opti is on
if info.tem.model.flags.runOpti
    disp('--------------------------')
    disp('optimize the SINDBAD model')
    disp('--------------------------')
    optimizerFunName                        =   ['optimizeTEM_' info.opti.algorithm.funName];
    if ~exist(optimizerFunName)
        optimizerFunName                    =   'optimizeTEM';
    end
    
    optimizerFunHandle                      =   str2func(optimizerFunName);
    [pScalesS]                              =   feval(optimizerFunHandle,f,obs,info);
    pScales                                 =   pScalesS.x;
    %      [pScales]   = optimizeTEM(f,obs,info);
    p                                       =   info.tem.params;
    for i                                   =   1:numel(info.opti.params.names)
        eval([info.opti.params.names{i} '   = info.opti.params.defaults(i) .* pScales(i);'])
    end
    disp('---------------------------------------------------')
    disp('Forward run SINDBAD model with optimized parameters')
    disp('---------------------------------------------------')
    [f,fe,fx,s,d,p,precOnceData,sSU,dSU]    = runTEM(info,f,p);
end

%% Save the data and model output
disp('----------------------------------------------------------------------')
disp('Save the info of the current experiment and corresponding forcing data')
disp('----------------------------------------------------------------------')
% create a copy of the configuration files of the experimentment to output directory
[pth,~,~] = fileparts(expConfigFile);
copyfile(pth,info.experiment.settingsOutputDirPath);
disp('Saved a copy of the configuration files')

% save the light version of info with all configs and settings as a json
% file
savejsonJL('',infoLite,info.experiment.outputInfoFile);
disp('Saved the light version of info in json format')

% save the info as mat file
save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate '_info.mat'], 'info', '-v7.3')
disp('Saved the full version of info in .mat format')

% save the f as mat file
save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate  '_f.mat'], 'f', '-v7.3')
disp('Saved the forcing for the experiment in .mat format')

%% move the temporary log file to model output directory
disp('--------------------------------------')
disp('END: Log of SINDBAD model experiment')
disp('--------------------------------------')

diary
movefile('tmpLogSINDBADrun____.txt',info.experiment.modelrunLogFile)
end
