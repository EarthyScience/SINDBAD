function test_LAISpinup(inpath,outpath,obspath,testName)
% a script to run an experiment to optimize one fluxnet site
% [uname,~] = getUserInfo();
% outpath=[outpath '/' uname];

% % workflow for debugging the casa with full carbon cycle to optimize one fluxnet site
% try
%     gone
% catch
% end
%
% %% setup working paths
% for fn = {'tools','model','optimization'} %,'sandbox/testBergBasic/','data/input/testInput_TWSmodel/'}
%     addpath(genpath(['../../' fn{1}]),'-begin')
% end
%
% %% Input and output path for the cCycle tests
% [uname,~] = getUserInfo();
% outpath=['/Net/Groups/BGI/work_3/sindbad/data/testBeds/output' '/' uname];
% % outpath='/Net/Groups/BGI/work_3/sindbad/data/testBeds/output';
% inpath='/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/NH_25.mat';
% testName='cCycleSpinup';


disp('%% go for the spinup')

toStore.CASA    = {
    's.w.wSoil'
    's.c.cEco'%
    's.cd.p_raAct_km4su'
    's.cd.cAlloc'
    's.cd.p_cTauAct_k'
    's.cd.p_cFlowAct_A'
    's.cd.p_cFlowAct_E'
    's.cd.p_cFlowAct_F'
    's.cd.p_cCycleBase_k'
    's.cd.p_cTaufLAI_kfLAI'
    's.cd.p_cTaufpSoil_kfSoil'
    's.cd.p_cTaufpVeg_kfVeg'
    'fe.cTaufTsoil.fT'
    };

toStore.simple    = {
    's.w.wSoil'
    's.c.cEco'%
    's.cd.p_raAct_km4su'
    's.cd.cAlloc'
    's.cd.p_cTauAct_k'
    's.cd.p_cFlowAct_A'
    's.cd.p_cCycleBase_k'
    's.cd.p_cTaufLAI_kfLAI'
    's.cd.p_cTaufpSoil_kfSoil'
    's.cd.p_cTaufpVeg_kfVeg'
    'fe.cTaufTsoil.fT'
    };

GPP2E           = 20;
cCycleModelVec  = {'CASA','simple'};
strExtra        = '';
compareModels    = true;
saveLongStates  = true;
% for NI2E = [11 101]% 1001 2001]
% NI2E=11s

for NI2E = [20]
    for cCycleModel = cCycleModelVec
        % name of the experiment configuration file
        expConfigFile               =   ['testBeds/LAISpinup/settings_LAISpinup/experiment_LAISpinup_' cCycleModel{:} '.json'];
        for i = [3 1 2]
            switch i
                case 1 % setup explicit spinup
                    strN        = '% setup explicit spinup';
                    strN2       = 'explicit';
                    zSequence   = struct(...
                        'funHandleSpin',{'runCoreTEM','runCoreTEM','runCoreTEM','runCoreTEM'},...
                        'funHandleStop',{[],[],[],[]},...
                        'funAddInputs',{{1,0,0},{0,1,0},{0,1,0},{0,1,0}},...
                        'nLoops',{1,GPP2E,NI2E+1,1}...
                        );
                case 2 % setup explicit spinup - using reduced code version for spin up
                    strN        = '% setup explicit spinup - using reduced code version for spin up';
                    strN2       = 'expliRed';
                    zSequence    = struct(...
                        'funHandleSpin',{'runCoreTEM','runCoreTEM','runCoreTEM','runCoreTEM'},...
                        'funHandleStop',{[],[],[],[]},...
                        'funAddInputs',{{1,0,0},{0,1,0},{0,1,1},{0,1,0}},...
                        'nLoops',{1,GPP2E,NI2E,1}...
                        );
                case 3 % implicit spin up
                    strN        = '% implicit spin up';
                    strN2       = 'implicit';
                    zSequence   = struct(...
                        'funHandleSpin',{'runCoreTEM','runCoreTEM',['spin_cCycle_' cCycleModel{:}],'runCoreTEM'},...
                        'funHandleStop',{[],[],[],[]},...
                        'funAddInputs',{{1,0,0},{0,1,0},{NI2E},{0,1,0}},...
                        'nLoops',{1,GPP2E,1,1}...
                        );
            end
            % output files names
            % log file
            %             if exist([oufile '.log'],'file'),delete([oufile '.log']),end
            %             diary([oufile '.log'])
            % current run
            disp(' ')
            disp([cCycleModel{:} ' : ' strN])
            % run the model
            tstart = tic;
            [f5,fe5,fx5,s5,d5,p5,precOnceData5,info,...
                fSU5,feSU5,fxSU5,sSU5,dSU5,precOnceDataSU5,infoSU5,...
                obs5,cost5] = workflowExperiment(expConfigFile,...
                'info.tem.forcing.oneDataPath',inpath,...
                'info.experiment.outputDirPath',outpath,...
                'info.experiment.name',testName,...
                'info.tem.spinup.sequence',zSequence,...
                'info.tem.spinup.flags.storeFullSpinupStates',saveLongStates,...
                'tem.model.flags.genCode',true,...
                'tem.model.flags.runGenCode',true,...
                'tem.model.variables.to.store',toStore.(cCycleModel{:}),...
                'tem.model.modules.LAI.apprName','constant',...
                'tem.model.modules.LAI.runFull',true,...
                'tem.model.modules.cCycle.apprName',cCycleModel{:});
            %
            test_outDirPath=[info.experiment.outputDirPath 'test_' testName '/'];
            mkdirx(test_outDirPath)
            oufile = [test_outDirPath 'sb_simpleVScasa_' strExtra num2str(NI2E) '_' cCycleModel{:}  '_' strN2];
            save([oufile '.mat'], 'info','f5','fe5','fx5','s5','d5','p5','precOnceData5','sSU5','dSU5','-v7.3')
            
            %%
            if saveLongStates
                figure('Visible', 'off'), hold on
                
                for j = 1:14
                    subplot(4,4,j)
                    if size(dSU5.fullSpinupStates.cEco,1) == 1
                        y   = [squeeze(dSU5.fullSpinupStates.cEco(:,j,:))' squeeze(d5.storedStates.cEco(:,j,:))']';
                    else
                        y   = [squeeze(dSU5.fullSpinupStates.cEco(:,j,:)) squeeze(d5.storedStates.cEco(:,j,:))]';
                    end
                    x    = (1:size(y,1));
                    plot(x,y,'lineWidth',2)
                    axis tight
                    set_gcf(gcf,gca,'s',1,[30 30],1)
                    title([num2str(j) ' : ' info.tem.model.variables.states.c.components{j}])
                end
                save_gcf(gcf,[test_outDirPath 'simpleVScasa_' strExtra num2str(NI2E) '_4_TS_' cCycleModel{:} '_' strN2 '_' testName],1,1)
                %%
            end
            clear f5 fe5 fx5 s5 d5 p5 precOnceData5 sSU5 dSU5
            %             diary('off')
        end
    end
    %%
    for cCycleModel = cCycleModelVec
        figure('Visible', 'off'), hold on
        % build the info
        for i = [1 2 3]
            switch i
                case 1 % setup explicit spinup
                    strN2       = 'explicit';
                case 2 % setup explicit spinup - using reduced code version for spin up
                    strN2       = 'expliRed';
                case 3 % implicit spin up
                    strN2       = 'implicit';
            end
            % output files names
            oufile = [test_outDirPath 'sb_simpleVScasa_' strExtra num2str(NI2E) '_' cCycleModel{:}  '_' strN2];
            % t=dir([oufile '.mat'])
            tmp = load([oufile '.mat']);
            clear f5 fe5 fx5 s5 d5 p5 precOnceData5 sSU5 dSU5
            eval(['x_' strN2 ' = tmp;'])
        end
        for j = 1:14
            subplot(4,4,j)
            mk121s(x_implicit.sSU5.c.cEco(:,j),x_explicit.sSU5.c.cEco(:,j),[cCycleModel{:} '_{implicit}'],[cCycleModel{:} '_{explicit}'],'LineWidth',2,'marker','o')
            mk121s(x_implicit.dSU5.storedStates.cEco(:,j,end),x_explicit.dSU5.storedStates.cEco(:,j,end),[cCycleModel{:} '_{implicit}'],[cCycleModel{:} '_{explicit}'],'LineWidth',2)
            title([num2str(j) ' : ' x_implicit.info.tem.model.variables.states.c.components{j}])
            set_gcf(gcf,gca,'s',1,[30 30],1)
        end
        subplot(4,4,15)
        mk121s(x_implicit.fx5.cRA,x_explicit.fx5.cRA,[cCycleModel{:} '_{implicit}'],[cCycleModel{:} '_{explicit}'],'LineWidth',2,'marker','o')
        title('RA')
        set_gcf(gcf,gca,'s',1,[30 30],1)
        subplot(4,4,16)
        mk121s(x_implicit.fx5.cRH,x_explicit.fx5.cRH,[cCycleModel{:} '_{implicit}'],[cCycleModel{:} '_{explicit}'],'LineWidth',2,'marker','o')
        title('RH')
        set_gcf(gcf,gca,'s',1,[30 30],1)
        
        save_gcf(gcf,[test_outDirPath 'simpleVScasa_' strExtra num2str(NI2E) '_4_compSpinUp_' cCycleModel{:} '_' testName],1,1)
    end
    %%
    if compareModels
        for i = [1 2 3]
            switch i
                case 1 % setup explicit spinup
                    strN2       = 'explicit';
                case 2 % setup explicit spinup - using reduced code version for spin up
                    strN2       = 'expliRed';
                case 3 % implicit spin up
                    strN2       = 'implicit';
            end
            figure('Visible', 'off'), hold on
            for cCycleModel = cCycleModelVec
                % build the info
                % output files names
                oufile = [test_outDirPath 'sb_simpleVScasa_' strExtra num2str(NI2E) '_' cCycleModel{:}  '_' strN2];
                tmp = load([oufile '.mat']);
                clear f5 fe5 fx5 s5 d5 p5 precOnceData5 sSU5 dSU5
                eval(['x_' cCycleModel{:} ' = tmp;'])
            end
            
            for j = 1:14
                subplot(4,4,j)
                mk121s(x_CASA.sSU5.c.cEco(:,j),x_simple.sSU5.c.cEco(:,j),['CASA_{' strN2 '}'],['simple_{' strN2 '}'],'LineWidth',2)
                title([num2str(j) ' : ' x_CASA.info.tem.model.variables.states.c.components{j}])
                set_gcf(gcf,gca,'s',1,[30 30],1)
                title([num2str(j) ' : ' x_implicit.info.tem.model.variables.states.c.components{j}])
            end
            save_gcf(gcf,[test_outDirPath 'simpleVScasa_'  strExtra num2str(NI2E) '_4_compModels_' strN2 '_' testName],1,1)
        end
    end
end
end