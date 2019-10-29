try
    gone
catch
end

%% setup paths
for fn = {'tools','model','optimization'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end

outpath='/Net/Groups/BGI/work_3/sindbad/data/testBeds/output';
inpath='/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/CalibrationTWSPaper_Forcing.mat';
testName='wCycleForward';
%% provide an experiment configuration file
expConfigFile               =   'testBeds/wCycleForward/settings_wCycleForward/experiment_wCycle.json';

%% run the experiment
% generated code and reduced memory array

[f_rm,fe_rm,fx_rm,s_rm,d_rm,p_rm,precOnceData_rm,info_rm,fSU_rm,feSU_rm,fxSU_rm,sSU_rm,dSU_rm,precOnceDataSU_rm,infoSU_rm,obs_rm,cost_rm] = ...
    workflowExperiment(expConfigFile,'info.tem.model.flags.genRedMemCode',true,...
    'info.tem.model.flags.runGenCode',true,...
    'info.tem.forcing.oneDataPath',inpath,...
    'info.experiment.name',testName,...
    'info.experiment.outputDirPath',outpath...
    );

% handles
[f_h,fe_h,fx_h,s_h,d_h,p_h,precOnceData_h,info_h,fSU_h,feSU_h,fxSU_h,sSU_h,dSU_h,precOnceDataSU_h,infoSU_h,obs_h,cost_h] = ...
    workflowExperiment(expConfigFile,'info.tem.model.flags.runGenCode',false,...
    'info.tem.forcing.oneDataPath',inpath,...
    'info.experiment.name',testName,...
    'info.experiment.outputDirPath',outpath...
    );
% generated code
[f_gc,fe_gc,fx_gc,s_gc,d_gc,p_gc,precOnceData_gc,info_gc,fSU_gc,feSU_gc,fxSU_gc,sSU_gc,dSU_gc,precOnceDataSU_gc,infoSU_gc,obs_gc,cost_gc] = ...
    workflowExperiment(expConfigFile,'info.tem.model.flags.runGenCode',true,...
    'info.tem.forcing.oneDataPath',inpath,...
    'info.experiment.name',testName,...
    'info.experiment.outputDirPath',outpath...
    );


%% FIGURES
fig_outDirPath=[info_rm.experiment.outputDirPath 'testOutputs/wCycle'];
mkdir(fig_outDirPath)
fNamesf=fields(f_h);
fNamesfx=fields(fx_h);
fNamesd=fields(d_h.storedStates);

% handles vs generated code
for fn = 1:numel(fNamesf)
    figure('Visible', 'off')
    mk121s(nanmean(f_h.(fNamesf{fn}),1),nanmean(f_gc.(fNamesf{fn}),1),['handle'],['generated'],'LineWidth',2,'marker','o')
    title(['forcing: temporal mean ' fNamesf{fn}])
    save_gcf(gcf,[fig_outDirPath '/forcing_' fNamesf{fn} '_handle_vs_generated_wCycle_Forward'],1,1)
end
for fn = 1:numel(fNamesfx)
    figure('Visible', 'off')
    mk121s(nanmean(fx_h.(fNamesfx{fn}),1),nanmean(fx_gc.(fNamesfx{fn}),1),['handle'],['generated'],'LineWidth',2,'marker','o')
    title(['flux: temporal mean ' fNamesfx{fn}])
    save_gcf(gcf,[fig_outDirPath '/fluxes_' fNamesfx{fn} '_handle_vs_generated_wCycle_Forward'],1,1)
end
for fn = 1:numel(fNamesd)
    figure('Visible', 'off')
    mk121s(nanmean(d_h.storedStates.(fNamesd{fn}),1),nanmean(d_gc.storedStates.(fNamesd{fn}),1),['handle'],['generated'],'LineWidth',2,'marker','o')
    title(['diagnostic stored states: temporal mean ' fNamesd{fn}])
    save_gcf(gcf,[fig_outDirPath '/diagnostics_' fNamesd{fn} '_handle_vs_generated_wCycle_Forward'],1,1)
end

% reduced array vs full array generated code
for fn = 1:numel(fNamesfx)
    figure('Visible', 'off')
    mk121s(fx_gc.(fNamesfx{fn})(:,end),fx_rm.(fNamesfx{fn})(:,end),['generated'],['reduced memory'],'LineWidth',2,'marker','o')
    %     scatter(mean(fx_h.(fNamesfx{fn}),1),mean(fx_gc.(fNamesfx{fn}),1))
    title(['flux: ' fNamesfx{fn} ' at tEnd'])
    save_gcf(gcf,[fig_outDirPath '/fluxes_' fNamesfx{fn} '_reducedMemory_vs_generated_wCycle_Forward'],1,1)
end
for fn = 1:numel(fNamesd)
    figure('Visible', 'off')
    mk121s(d_gc.storedStates.(fNamesd{fn})(:,end),d_rm.storedStates.(fNamesd{fn})(:,end),['generated'],['reduced memory'],'LineWidth',2,'marker','o')
    title(['diagnostic stored states: ' fNamesd{fn} ' at tEnd'])
    save_gcf(gcf,[fig_outDirPath '/diagnostics_' fNamesd{fn} '_reducedMemory_vs_generated_wCycle_Forward'],1,1)
end



% reduced array vs full array handle code
for fn = 1:numel(fNamesfx)
    figure('Visible', 'off')
    mk121s(fx_h.(fNamesfx{fn})(:,end),fx_rm.(fNamesfx{fn})(:,end),['handle'],['reduced memory'],'LineWidth',2,'marker','o')
    %     scatter(mean(fx_h.(fNamesfx{fn}),1),mean(fx_gc.(fNamesfx{fn}),1))
    title(['flux: ' fNamesfx{fn} ' at tEnd'])
    save_gcf(gcf,[fig_outDirPath '/fluxes_' fNamesfx{fn} '_reducedMemory_vs_handle_wCycle_Forward'],1,1)
end
for fn = 1:numel(fNamesd)
    figure('Visible', 'off')
    mk121s(d_h.storedStates.(fNamesd{fn})(:,end),d_rm.storedStates.(fNamesd{fn})(:,end),['handle'],['reduced memory'],'LineWidth',2,'marker','o')
    title(['diagnostic stored states: ' fNamesd{fn} ' at tEnd'])
    save_gcf(gcf,[fig_outDirPath '/diagnostics_' fNamesd{fn} '_reducedMemory_vs_handle_wCycle_Forward'],1,1)
end

