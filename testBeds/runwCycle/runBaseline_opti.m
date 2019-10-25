%% setup paths
for fn = {'tools','model','optimization','data'}
    addpath(genpath(['../../' fn{1}]),'-begin')
    addpath(genpath('../../sandbox/sb_Tina'))
end

% global optimization - baseline variant 1
expConfigFile               =   'settings/Tina_baseline/experiment_runOpti904.json';

% run the experiment without opti
[f,fe,fx,s,d,p,precOnceData,info,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU,obs,cost] = workflowExperiment(expConfigFile, 'info.tem.model.flags.runOpti', false);%,...

% run the experiment with opti
[f,fe,fx,s,d,p,precOnceData,info,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU,obs,cost] = workflowExperiment(expConfigFile);
 
 
  
  