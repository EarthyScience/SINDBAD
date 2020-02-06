%% clean the path and memory
try
    gone
    for fn              =	{'tools','model','optimization','testBeds'}
        rmpath(genpath(['../../' fn{1}]))
    end
catch
end

%% add the paths of the necessary sindbad directories

for fn                  =	{'tools','model','optimization','testBeds'}
    addpath(genpath(['../../' fn{1}]),'-begin')
end

% %Tina
userInPath              =   'C:/Users/ttraut/Documents/SindbadTestData/input/';
userOutPath             =   'C:/Users/ttraut/Documents/SindbadTestData/output/';

if isempty(userInPath)
    inDir               =   '/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/';
else
    inDir               =   userInPath;
end

if isempty(userOutPath)
    outDir              =   '/Net/Groups/BGI/work_3/sindbad/data/testBeds/output/';
    [uname,~]           =	getUserInfo();
    outDir              =   [outDir '/' uname];
else
    outDir              =   userOutPath;
end

%% generate the inpath and experiment config
inpath                  =   [inDir '/' 'globalTWS_Forcing.mat'];
obspath                 =   '';
testName                =   'wCycleCheck';
outpath                 =   outDir;
expConfigFile           =   ['testBeds/approachChecks/settings_' testName '/experiment_' testName '.json'];

%% set the module to be checked
moduleName              = 'wSnowFrac';

% run the wCycleForward
checkApproach_wCycleForward_ttraut(moduleName,inpath,obspath,testName,outpath,expConfigFile)

% run the cCycleForward
checkApproach_cCycleForward_ttraut(moduleName,inpath,obspath,testName,outpath,expConfigFile)
