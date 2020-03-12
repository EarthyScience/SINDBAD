%% clean the path and memory
try
    gone
catch
end
try
    for fn              =    {'tools','model','optimization','testBeds'}
        rmpath(genpath(['../../' fn{1}]))
    end
catch
end

%% add the paths of the necessary sindbad directories

for fn                  =    {'tools','model','optimization','testBeds'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end
%%
userInPath              =   '/home/simon/Desktop/sindbad_data/data/testBeds/input';
userOutPath             =   '/home/simon/Desktop/sindbad_data/data/testBeds/output';

if isempty(userInPath)
    inDir               =   '/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/';
else
    inDir               =   userInPath;
end

if isempty(userOutPath)
    outDir              =   '/Net/Groups/BGI/work_3/sindbad/data/testBeds/output/';
    [uname,~]           =    getUserInfo();
    outDir              =   [outDir '/' uname];
else
    outDir              =   userOutPath;
end

%% generate the inpath and experiment config
inpath                  =   [inDir '/' 'US-Ha1.2000-2015.nc'];
obspath                 =   inpath;
testName                =   'cCycleCheck';
outpath                 =   outDir;
expConfigFile           =   ['testBeds/approachChecks/settings_' testName '/experiment_' testName '.json'];


%% set the module to be checked
moduleName              = 'cFlowAct';
figsInterest = {'gpp' 'cRH' 'cRA' 'cRECO'};

%% stop if module does not exist
moduleDir             = [sindbadroot 'model/modules/' moduleName];
if ~exist(moduleDir,'dir')
    disp(['Module ' moduleDir ' does not exist'])
    return
end
%% settings for spinup
zSequence   = struct(...
    'funHandleSpin',{'runCoreTEM','runCoreTEM','spin_cCycle_CASA','runCoreTEM'},...
    'funHandleStop',{[],[],[],[]},...
    'funAddInputs',{{1,0,0},{0,1,0},{11},{1,1,0}},...
    'nLoops',{1,10,1,1}...
    );

%% get the list of modules and approaches and run every possible experiment
%% get the list of modules and approaches and run every possible experiment
[appDirs,~] = getFiles(moduleDir,'m');
runNum = 0;
expNames ={};
opList={'fx','s' 'd' 'info'};
moduleInfo = struct;
rgenCode = {0 1};
grCode = {0 1};
runGenCode  = 0;
genRedMemCode = 0;
tryCatch = 0;
% rgenCode = {0};
% grCode = {1};
for a=1:2
    runGenCode = rgenCode{a};
    %for b = 1:4
    for b = 1:2
        genRedMemCode = grCode{b};
        %for ap = 1:numel(appDirs)
        for ap = 3        
            tmp=strsplit(appDirs{ap},'_');
            appName = tmp(end);
            moduleInfo.(char(appName)).precFile = false;
            moduleInfo.(char(appName)).dynaFile = false;
            moduleInfo.(char(appName)).fullFile = false;
            fullappName = [moduleName '_' appName];
            if iscell(fullappName)
                fullappName=horzcat(fullappName{:});
            end
            if strcmp(appName,'dummy')
                disp(['dummy approach exists for ' moduleName])
                dummyFile = 1;
                moduleInfo.(char(appName)).dummyFile    = true;
                moduleInfo.(char(appName)).fullFile     = true;
            else
                [~,appFiles]=getFiles(appDirs{ap},'m');
                appMfiles= {appFiles(:).name};
                precFile=0;dynaFile=0;fullFile=0;
                for apFN = 1:numel(appMfiles)
                    [~,fileN,~] = fileparts(appMfiles{apFN});
                    if ~isempty(strfind(fileN, 'prec_'))
                        disp('prec exists')
                        precFile=true;
                        moduleInfo.(char(appName)).precFile = true;
                    end
                    if ~isempty(strfind(fileN, 'dyna_'))
                        disp('dyna exists')
                        dynaFile = true;
                        moduleInfo.(char(appName)).dynaFile = true;
                    end
                    if isempty(strfind(fileN, 'dyna_')) && isempty(strfind(fileN, 'prec_'))
                        disp('full file exists')
                        fullFile=true;
                        moduleInfo.(char(appName)).fullFile = true;
                    end
                end
                if runGenCode == 0 && genRedMemCode == 1
                    disp('does not make sense to run memory reduced code')
                else
                    if precFile && dynaFile
                        expName=['gc-' num2str(runGenCode) '_rdm-' num2str(genRedMemCode) '_' testName '_' fullappName '_precDyna'];
                        if iscell(expName)
                            expName = horzcat(expName{:});
                        end
                        modString=['info.tem.model.modules.' moduleName '.apprName'];
                        runString=['info.tem.model.modules.' moduleName '.runFull'];
                        if tryCatch
                            try
                                [f,fe,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                                    workflowExperiment(expConfigFile,...
                                    'info.tem.model.flags.genRedMemCode',genRedMemCode,...
                                    'info.tem.model.flags.runGenCode',runGenCode,...
                                    'info.tem.forcing.oneDataPath',inpath,...
                                    'info.experiment.name',expName,...
                                    'info.tem.spinup.sequence',zSequence,...
                                    'info.tem.spinup.flags.recycleMSC', true,...
                                    'info.opti.constraints.oneDataPath',obspath,...
                                    modString,char(appName),...
                                    runString,false,...
                                    'info.experiment.outputDirPath',outpath...
                                    );
                                runNum = runNum+1;
                                expNames=[expNames expName];
                                for opN = 1:numel(opList)
                                    opName = opList{opN};
                                    eval([opName num2str(runNum) '=' opName ';'])
                                end
                                disp(['Prec and Dyna of approaches exists for ' fullappName])
                            catch e %e is an MException struct
                                fprintf(1,'The identifier was:\n%s',e.identifier);
                                fprintf(1,'There was an error! The message was:\n%s',e.message);
                                %                     save([moduleName '_' appName '.mat'], 'e','-v7.3')
                                %                     save(char([moduleName '_' appName '.mat']), 'e','-v7.3')
                                disp(['approach ' appName ' does not run'])
                            end
                        else
                            [f,fe,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                                workflowExperiment(expConfigFile,...
                                'info.tem.model.flags.genRedMemCode',genRedMemCode,...
                                'info.tem.model.flags.runGenCode',runGenCode,...
                                'info.tem.forcing.oneDataPath',inpath,...
                                'info.experiment.name',expName,...
                                'info.tem.spinup.sequence',zSequence,...
                                'info.tem.spinup.flags.recycleMSC', true,...
                                'info.opti.constraints.oneDataPath',obspath,...
                               modString,char(appName),...
                                runString,false,...
                                'info.experiment.outputDirPath',outpath...
                                );
                            runNum = runNum+1;
                            expNames=[expNames expName];
                            for opN = 1:numel(opList)
                                opName = opList{opN};
                                eval([opName num2str(runNum) '=' opName ';'])
                            end
                            disp(['Prec and Dyna of approaches exists for ' fullappName])
                            
                        end
                        %
                    end
                    if fullFile
                        expName=['gc-' num2str(runGenCode) '_rdm-' num2str(genRedMemCode) '_' testName '_' fullappName '_full'];
                        if iscell(expName)
                            expName = horzcat(expName{:});
                        end
                        modString=['info.tem.model.modules.' moduleName '.apprName'];
                        runString=['info.tem.model.modules.' moduleName '.runFull'];
                        if tryCatch
                            try
                                [f,fe,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                                    workflowExperiment(expConfigFile,...
                                    'info.tem.model.flags.genRedMemCode',genRedMemCode,...
                                    'info.tem.model.flags.runGenCode',runGenCode,...
                                    'info.tem.forcing.oneDataPath',inpath,...
                                    'info.experiment.name',expName,...
                                    'info.tem.spinup.sequence',zSequence,...
                                    'info.tem.spinup.flags.recycleMSC', true,...
                                    'info.opti.constraints.oneDataPath',obspath,...
                                    modString,char(appName),...
                                    runString,true,...
                                    'info.experiment.outputDirPath',outpath...
                                    );
                                runNum = runNum+1;
                                expNames=[expNames expName];
                                for opN = 1:numel(opList)
                                    opName = opList{opN};
                                    eval([opName num2str(runNum) '=' opName ';'])
                                end
                                disp(['Prec and Dyna of approaches exists for ' fullappName])
                            catch e %e is an MException struct
                                fprintf(1,'The identifier was:\n%s',e.identifier);
                                fprintf(1,'There was an error! The message was:\n%s',e.message);
                                %                     save(char([moduleName '_' appName '.mat']), 'e','-v7.3')
                                disp(['approach ' appName ' does not run'])
                            end
                        else
                            [f,fe,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                                workflowExperiment(expConfigFile,...
                                'info.tem.model.flags.genRedMemCode',genRedMemCode,...
                                'info.tem.model.flags.runGenCode',runGenCode,...
                                'info.tem.forcing.oneDataPath',inpath,...
                                'info.experiment.name',expName,...
                                'info.tem.spinup.sequence',zSequence,...
                                'info.tem.spinup.flags.recycleMSC', true,...
                                'info.opti.constraints.oneDataPath',obspath,...
                                modString,char(appName),...
                                runString,true,...
                                'info.experiment.outputDirPath',outpath...
                                );
                            runNum = runNum+1;
                            expNames=[expNames expName];
                            for opN = 1:numel(opList)
                                opName = opList{opN};
                                eval([opName num2str(runNum) '=' opName ';'])
                            end
                        end
                        
                        
                    end
                end
                %         [~,~,~] = getModuleVariableMatrix(info);
            end
        end
    end
end

%% summary of files
% if dummyFile == 1
%     disp(['Dummy approach exists for ' moduleName])
% else
%         disp(['Dummy approach DOES NOT exist for ' moduleName])
% end

%% plot the comparison figures

fig_outDirPath=[info.experiment.outputDirPath '../checkResults_' moduleName];
mkdirx(fig_outDirPath)
fNamesfx=fields(fx);
fNamesd=fields(d.storedStates);
nColo = runNum/3;
colors = {'b' 'k' 'r' 'g' 'y' 'c' 'm'};
markers = {'+' 'o' 'x'};
for fn = 1:numel(fNamesfx)
    coloNum =1;
    markerNum = 1;
    if ismember(fNamesfx{fn},figsInterest)
        figure('Visible', 'off')
        hold on
        for rn = 1:1:runNum
            eval(['dat=fx' num2str(rn) '.' fNamesfx{fn} ';'])
            try
                plot(nanmean(dat,1),'LineWidth',0.01,'Color',colors{coloNum},'Marker',markers{markerNum},'MarkerIndices',1:100:length(dat))
%                 rn
%                 nColo
                if rem(rn,nColo) == 0
%                     disp('marker change')
                    coloNum = 1;
                    markerNum = markerNum + 1;
                else
                    disp('color change')
                    coloNum = coloNum + 1;
                end

            catch
                disp([expNames{rn} ' failed to plot ' fNamesfx{fn} ])
            end
        end
        hleg = legend(expNames);
        set(hleg,'Interpreter', 'none')
        titl=title(['flux: spatial mean ' fNamesfx{fn}]);
        set(titl,'Interpreter', 'none');
        if ismember(fNamesfx{fn},figsInterest)
            savefig([fig_outDirPath '/' moduleName '_' fNamesfx{fn} '.fig'])
        end
        
                save_gcf(gcf,[fig_outDirPath '/' moduleName '_' fNamesfx{fn}],1,1)
    end
end
for fn = 1:numel(fNamesd)
    coloNum =1;
    markerNum = 1;
    if ismember(fNamesd{fn},figsInterest)
        figure('Visible', 'off')
        hold on
        for rn = 1:1:runNum
            eval(['dat=d'  num2str(rn) '.storedStates.' fNamesd{fn} ';'])
            dat=squeeze(dat);
            try
                if ndims(dat) > 2
                    datMean=nansum(nanmean(dat,[1]),[2]);
                else
                    datMean=nanmean(dat,1);
                end
                plot(datMean,'LineWidth',0.01,'Color',colors{coloNum},'Marker',markers{markerNum},'MarkerIndices',1:100:length(datMean))
                if rem(rn,nColo) == 0
                    coloNum = 1;
                    markerNum = markerNum + 1;
                else
                    coloNum = coloNum + 1;
                end
            catch
                disp([expNames{rn} ' failed to plot ' fNamesd{fn} ])
            end
        end
         hleg = legend(expNames);
        set(hleg,'Interpreter', 'none')
        titl=title(['diagnostic stored states: spatial mean ' fNamesd{fn}]);
        set(titl,'Interpreter', 'none');
        if ismember(fNamesd{fn},figsInterest)
            savefig([fig_outDirPath '/' moduleName '_' fNamesd{fn} '.fig'])
        end
    end
    save_gcf(gcf,[fig_outDirPath '/' moduleName '_' fNamesd{fn}],1,1)
    
end


%% function to get the file list
function [listOfFolderNames,baseFileNames] = getFiles(start_path,ext)
% Start with a folder and get a list of all subfolders.
% Finds and prints names of all files with extension ext

% Get list of all subfolders.
topLevelFolder = start_path;
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
    [singleSubFolder, remain] = strtok(remain, ':');
    if isempty(singleSubFolder)
        break;
    end
    listOfFolderNames = [listOfFolderNames singleSubFolder];
end
if length(listOfFolderNames) > 1
    listOfFolderNames = listOfFolderNames(2:end);
end
numberOfFolders = length(listOfFolderNames);

% Process all image files in those folders.
for k = 1 : numberOfFolders
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k};
    fprintf('Processing folder %s\n', thisFolder);
    
    % Get m files.
    filePattern = sprintf(['%s/*.' ext], thisFolder);
    baseFileNames = dir(filePattern);
end
end
