function [] = checkApproach_wCycleForward_ttraut(moduleName,inpath,obspath,testName,outpath,expConfigFile)
%% stop if module does not exist
moduleDir             = [sindbadroot 'model/modules/' moduleName];
if ~exist(moduleDir,'dir')
    disp(['Module ' moduleDir ' does not exist'])
    return
end

%% get the list of modules and approaches and run every possible experiment
[appDirs,~] = getFiles(moduleDir,'m');
runNum = 0;
expNames ={};
opList={'fx','s' 'd' 'info'};
moduleInfo = struct;
for ap = 1:numel(appDirs)
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
        if precFile && dynaFile
            runNum = runNum+1;
            expName=[testName '_' fullappName '_precDyna'];
            if iscell(expName)
                expName = horzcat(expName{:});
            end
            modString=['info.tem.model.modules.' moduleName '.apprName'];
            runString=['info.tem.model.modules.' moduleName '.runFull'];
            [~,~,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                workflowExperiment(expConfigFile,...
                'info.tem.model.flags.runGenCode',true,...
                'info.tem.forcing.oneDataPath',inpath,...
                'info.experiment.name',expName,...
                modString,char(appName),...
                runString,false,...
                'info.experiment.outputDirPath',outpath...
                );
            expNames=[expNames expName];
            for opN = 1:numel(opList)
                opName = opList{opN};
                eval([opName num2str(runNum) '=' opName ';'])
            end
            disp(['Prec and Dyna of approaches exists for ' fullappName])
            
        end
        if fullFile
            runNum = runNum+1;
            expName=[testName '_' fullappName '_full'];
            if iscell(expName)
                expName = horzcat(expName{:});
            end
            modString=['info.tem.model.modules.' moduleName '.apprName'];
            runString=['info.tem.model.modules.' moduleName '.runFull'];
            [~,~,fx,s,d,~,~,info,~,~,~,~,~,~,~,~,~] = ...
                workflowExperiment(expConfigFile,...
                'info.tem.model.flags.runGenCode',true,...
                'info.tem.forcing.oneDataPath',inpath,...
                'info.experiment.name',expName,...
                modString,char(appName),...
                runString,true,...
                'info.experiment.outputDirPath',outpath...
                );
            expNames=[expNames expName];
            for opN = 1:numel(opList)
                opName = opList{opN};
                eval([opName num2str(runNum) '=' opName ';'])
            end
            disp(['Prec and Dyna of approaches exists for ' fullappName])
            
        end
        [~,~,~] = getModuleVariableMatrix(info);
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
for fn = 1:numel(fNamesfx)
    figure('Visible', 'off')
    hold on
    for rn = 1:1:runNum
        eval(['dat=fx' num2str(rn) '.' fNamesfx{fn} ';'])
        plot(nanmean(dat,1),'LineWidth',1)
    end
    hleg = legend(expNames);
    set(hleg,'Interpreter', 'none')
    titl=title(['flux: spatial mean ' fNamesfx{fn}]);
    set(titl,'Interpreter', 'none');
    save_gcf(gcf,[fig_outDirPath '/' moduleName '_' fNamesfx{fn}],1,1)
end
for fn = 1:numel(fNamesd)
    figure('Visible', 'off')
    hold on
    for rn = 1:1:runNum
        eval(['dat=d'  num2str(rn) '.storedStates.' fNamesd{fn} ';'])
        dat=squeeze(dat);
        if ndims(dat) > 2
            datMean=nansum(nanmean(dat2,[1]),[2]);
        else
            datMean=nanmean(dat,1);
        end
        plot(datMean,'LineWidth',1)
    end
    hleg = legend(expNames);
    set(hleg,'Interpreter', 'none')
    titl=title(['diagnostic stored states: spatial mean ' fNamesd{fn}]);
    set(titl,'Interpreter', 'none');
    save_gcf(gcf,[fig_outDirPath '/' moduleName '_' fNamesd{fn}],1,1)
    
end

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
    [singleSubFolder, remain] = strtok(remain, ';');
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
