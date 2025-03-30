function test_cCycleOpti(inpath,outpath,obspath,testName)
% a script to run an experiment to optimize one fluxnet site
% [uname,~] = getUserInfo();
% outpath=[outpath '/' uname];


if isempty(obspath)
    obspath=inpath;
    disp(['empty ipath: using inpath as obspath:' inpath])
else
    disp(['user defined obspath:' obspath])
end

% try
%     gone
% catch
% end
% 
% %% setup paths
% for fn = {'tools','model','optimization'}
%     addpath(genpath(['../../' fn{1}]),'-begin')
% end
% 
% [uname,~] = getUserInfo();
% 
% outpath=['/Net/Groups/BGI/work_3/sindbad/data/testBeds/output' '/' uname];
% 
% inpath='/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/US-Ha1.2000-2015.nc';
% testName='cCycleOpti';
%% provide an experiment configuration file
expConfigFile               =   'testBeds/cCycleOpti/settings_cCycleOpti/experiment_runOpti.json';

% creating the spinup sequence
zSequence   = struct(...
'funHandleSpin',{'runCoreTEM','runCoreTEM','spin_cCycle_CASA','runCoreTEM'},...
'funHandleStop',{[],[],[],[]},...
'funAddInputs',{{1,0,0},{0,1,0},{21},{1,1,0}},...
'nLoops',{1,2,1,1}...
); 

%% run the experiment
[f_def,fe_def,fx_def,s_def,d_def,p_def,precOnceData_def,info_def...
    ,fSU_def,feSU_def,fxSU_def,sSU_def,dSU_def,precOnceDataSU_def,infoSU_def,obs_def,cost_def] = workflowExperiment(expConfigFile,...
    'info.tem.model.flags.runOpti',false,...
    'info.tem.model.flags.calcCost',false,...
    'info.tem.spinup.sequence',zSequence,...
    'info.tem.spinup.flags.recycleMSC', true,...
    'info.tem.spinup.flags.saveSpinup', false,...
    'info.tem.model.flags.runGenCode',true,...
    'info.tem.forcing.oneDataPath',inpath,...
    'info.experiment.outputDirPath',outpath,...
    'info.opti.constraints.oneDataPath',obspath,...
    'info.experiment.name',testName...
    );





[f_opt,fe_opt,fx_opt,s_opt,d_opt,p_opt,precOnceData_opt,info_opt,...
    fSU_opt,feSU_opt,fxSU_opt,sSU_opt,dSU_opt,precOnceDataSU_opt,infoSU_opt,obs_opt,cost_opt] = workflowExperiment(expConfigFile,...
    'info.tem.spinup.sequence',zSequence,...
    'info.tem.spinup.flags.recycleMSC', true,...
    'info.tem.spinup.flags.saveSpinup', false,...
    'info.tem.model.flags.runGenCode',true,...
    'info.tem.forcing.oneDataPath',inpath,...
    'info.experiment.outputDirPath',outpath,...
    'info.experiment.name',testName,...
    'info.opti.constraints.oneDataPath',obspath...
    );


%% FIGURES
fig_outDirPath=[info_def.experiment.outputDirPath 'test_' testName];
mkdirx(fig_outDirPath)
fNamesf=fields(f_def);
fNamesfx=fields(fx_def);
fNamesd=fields(d_def.storedStates);

% handles vs generated code
for fn = 1:numel(fNamesf)
    figure('Visible', 'off')
    mk121s(nanmean(f_def.(fNamesf{fn}),1),nanmean(f_opt.(fNamesf{fn}),1),['default'],['optimized'],'LineWidth',2,'marker','o')
    title(['forcing: all time steps ' fNamesf{fn}])
    save_gcf(gcf,[fig_outDirPath '/forcing_' fNamesf{fn} '_default_vs_optimized_' testName],1,1)
end
for fn = 1:numel(fNamesfx)
    figure('Visible', 'off')
    mk121s(nanmean(fx_def.(fNamesfx{fn}),1),nanmean(fx_opt.(fNamesfx{fn}),1),['default'],['optimized'],'LineWidth',2,'marker','o')
    title(['flux: all time steps ' fNamesfx{fn}])
    save_gcf(gcf,[fig_outDirPath '/fluxes_' fNamesfx{fn} '_default_vs_optimized_wCycle_Forward'],1,1)
end
for fn = 1:numel(fNamesd)
    figure('Visible', 'off')
    mk121s(nanmean(d_def.storedStates.(fNamesd{fn}),1),nanmean(d_opt.storedStates.(fNamesd{fn}),1),['default'],['optimized'],'LineWidth',2,'marker','o')
    title(['diagnostic stored states: all time steps ' fNamesd{fn}])
    save_gcf(gcf,[fig_outDirPath '/diagnostics_' fNamesd{fn} '_default_vs_optimized_' testName],1,1)
end

