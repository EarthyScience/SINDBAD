% a script to get the info for an experiment to make forward run for one fluxnet site
%% setup paths
for fn = {'tools','model','optimization'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end

%% provide an experiment configuration file
expConfigFile               =   'settings/runOpti_FluxNet/experiment_runForward.json';

%% get the info
[info] = workflowInfo(expConfigFile);
%% unfold the info and save it
diaryName= 'info_Forward.txt';
if (exist(diaryName,'file'))
  delete(diaryName);
end
diary(diaryName)
unfold(info,'info',false)
diary
