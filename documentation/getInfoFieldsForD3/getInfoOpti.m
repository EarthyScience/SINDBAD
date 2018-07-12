% a script to get the info for an experiment to optimize one fluxnet site
%% setup paths
for fn = {'tools','model','optimization'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end

%% provide an experiment configuration file
expConfigFile               =   'settings/runOpti_FluxNet/experiment_runOpti.json';

%% get the info
[info] = workflowInfo(expConfigFile);
%% unfold the info and save it
diaryName= 'info_Opti.txt';
if (exist(diaryName,'file'))
  delete(diaryName);
end
diary(diaryName)
unfold(info,'info',false)
diary