% a script to run an experiment with the default parameters for 1000 pixel in the Northern
% hemisphere (Trautmann, TWS paper, HESS 2018)
try
gone
catch
end

% %% load the default results of the paper
% load('M:\people\ttraut\MATLAB\Paper.Data\ExpStruct_newStudy_E2bScal_1000pix_Cal_Paper.mat')
% load('M:\people\ttraut\MATLAB\Paper.Data\ModelSettings_Paper.mat')
% load('M:\people\ttraut\MATLAB\Paper.Results\Output\Optim_NewStudy_Default\Default1000_bergBasicCMAES_Paper.mat')
% 
% 
% clearvars -except Results ExpStruct ModelSettings

%% setup paths
for fn = {'tools','model','optimization'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end

%% provide an experiment configuration file
expConfigFile               =   'testBeds/runwCycle/settings_runwCycle/experiment_wCycle.json';

%% run the experiment
[f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,info,obs,cost] = workflowExperiment(expConfigFile,'info.tem.model.flags.genRedMemCode',true,'info.tem.model.flags.runGenCode',true);

[f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,info,obs,cost] = workflowExperiment(expConfigFile,'info.tem.model.flags.runGenCode',false);


[f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,info,obs,cost] = workflowExperiment(expConfigFile,'info.tem.model.flags.runGenCode',true);

% [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,info,obs,cost] = workflowExperiment(expConfigFile,'info.tem.model.flags.genRedMemCode',true,'info.tem.model.flags.runGenCode',true);

%% FIGURES
fNamesf=fields(f);
fNamesfx=fields(fx);
fNamesd=fields(d.storedStates);
for fn = 1:numel(fNamesf)
    figure
    scatter(mean(f.(fNamesf{fn}),1),mean(f.(fNamesf{fn}),1))
    title(['forcing: ' fNamesf{fn}])
end
for fn = 1:numel(fNamesfx)
    figure
    scatter(mean(fx.(fNamesfx{fn}),1),mean(fx.(fNamesfx{fn}),1))
    title(['flux: ' fNamesfx{fn}])
end
for fn = 1:numel(fNamesd)
    figure
    scatter(mean(squeeze(d.storedStates.(fNamesd{fn})),1),mean(squeeze(d.storedStates.(fNamesd{fn})),1))
    title(['diagnostic stored states: ' fNamesd{fn}])
end


%% looking at Q
figure, scatter(mean(fx.Q,1),mean(fx.Qb,1)),xlabel('Q'), ylabel('Qb')
figure, scatter(mean(fx.Q,1),mean(fx.Qint,1)),xlabel('Q'), ylabel('Qint')
figure, scatter(mean(fx.Q,1),mean(fx.Qint+fx.Qb,1)),xlabel('Q'), ylabel('Qint+Qb')


