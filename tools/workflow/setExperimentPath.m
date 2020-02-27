function [ info ] = setExperimentPath(info)
% Usages:
%   [info] = setExperimentPaths(info)
%
% Requires:
%   + the info:
%       ++ after reading the experiment.json file
%
% Purposes:
%   + creates the outputInfoFilename
%   + creates the paths for model run and generated code within the info
%   based on the outputDirPath in the experiment.json
%       ++ if no/only whitespace for outputDirPath is given, a default name
%       using the experiment name, domain and runDate is defined
%       ++ if the output directory already exists, a new path using
%       the experiment name, domain and runDate is created as subfolder
%   + checks if paths of forcing and constraints exists and converts them
%   to absolute paths

% Conventions:
%   + whitespaces are removed
%   + instead, one could do this: strrep(strrep(tmpStrName,' ','_'),'-','_')
%
% Created by:
%   + Tina Trautmann (ttraut)
%
% References:
%   +
%
% Versions:
%   + 1.0 on 22.06.2018
%   + 1.1 on 27.02.2020: skoirala: change the names of the generated code to shorten it

%% check if the experiment name, domain and runDate exist
if isfield(info.experiment, 'name')
    info.experiment.name(info.experiment.name == ' ') = [];
    name = info.experiment.name;
else
    name = 'SINDBAD_Experiment';
    info.experiment.name = name;
end

if isfield(info.experiment, 'domain')
    info.experiment.domain(info.experiment.domain== ' ') = [];
    domain = info.experiment.domain;
end

% default for experiment / path name
default_tmp = [name '_' domain '_' info.experiment.runDate];

%% check if the outputDirPath is given in the info
if isfield(info.experiment, 'outputDirPath')
    info.experiment.outputDirPath(info.experiment.outputDirPath == ' ') = [];
    if ~isempty(info.experiment.outputDirPath)
        info.experiment.outputDirPath  = replace(info.experiment.outputDirPath,{'/','\'},'/');
        % check whether it is an absolute path
        if strcmp(getFullPath(info.experiment.outputDirPath), info.experiment.outputDirPath)==1
            outputDirPath_full = [info.experiment.outputDirPath];
            %            outputDirPath_full = [info.experiment.outputDirPath '/'
            %            default_tmp '/']; %sujan
        else
            outputDirPath_full = convertToFullPaths(info,info.experiment.outputDirPath);
        end
    else
        outputDirPath_def               = ['data' '/' 'output'];
        %         outputDirPath_def               = ['data' '/' 'output'
        %         '/' default_tmp '/']; %sujan
        outputDirPath_full              = convertToFullPaths(info,outputDirPath_def);
        disp(['WARN PATH: setExperimentPaths : no "outputDirPath" was provided : a default path is created: ' outputDirPath_full  ])
    end
else
    % default output directory
    %     outputDirPath_def               = ['output' '/' default_tmp
    %     '/']; %sujan
    outputDirPath_def               = ['data' '/' 'output'];
    
    outputDirPath_full              = convertToFullPaths(info,outputDirPath_def);
    disp(['WARN PATH: setExperimentPaths: no "outputDirPath" was provided : a default path is created: ' outputDirPath_full  ])
end

outputDirPath_full = [outputDirPath_full '/' default_tmp '/'];


%% check if the outputDirPath already exists -> if so, rename it
% sujan... only create one folder per experiment per day.
% ii = 0;
% outputDirPath_new = outputDirPath_full;
% while exist(outputDirPath_new, 'dir')
%     outputDirPath_new  =    [outputDirPath_full default_tmp '_v' num2str(ii) '/'];
%     ii = ii+1;
% end
%
% if ii > 0
%     outputDirPath_full =    outputDirPath_new;
%     default_tmp        =    [default_tmp '_v' num2str(ii)];
%     disp(['MSG : setupTEM : the outputDirPath: ' info.experiment.outputDirPath ' already exists' newline  'a default output path is created: ' outputDirPath_new  ])
% end

%% put the full outputDirPath in the info
info.experiment.outputDirPath    =   outputDirPath_full;

%% set the output info.json file -should this be a filename or absolute path?
info.experiment.outputInfoFile          =    [outputDirPath_full '/' 'settings' '/' 'Info_' default_tmp '.json'];
info.experiment.modelOutputDirPath      =    [outputDirPath_full '/' 'modelOutput' '/'];
info.experiment.settingsOutputDirPath   =    [outputDirPath_full '/' 'settings' '/'];

if ~exist(info.experiment.outputDirPath, 'dir')
    mkdirx(info.experiment.outputDirPath)
end
if ~exist(info.experiment.modelOutputDirPath, 'dir')
    mkdirx(info.experiment.modelOutputDirPath)
end
if ~exist(info.experiment.settingsOutputDirPath, 'dir')
    mkdirx(info.experiment.settingsOutputDirPath)
end


%% set the runDir path
info.tem.model.paths.runDir    =    info.experiment.outputDirPath;

%% set the generated code filenames into the info
% info     = setGenCodePaths(info);
% unique name for the generated code files according to experiment name and to runDate.

% tmpStrName    = [info.experiment.name '_' info.experiment.domain '_' info.experiment.runDate]; %sujan: remove domain from generated code names to shorten them
tmpStrName    = [info.experiment.name '_' info.experiment.runDate];
tmpStrName  = strrep(strrep(tmpStrName,' ','_'),'-','_');


for n1 = {'model','spinup'}
    str1 = '';
    if strcmp(n1{1},'spinup'),str1='_SU';end
    for n2 = {'coreTEM','preCompOnce'}
        str2 = 'c';
        if strcmp(n2{1},'preCompOnce'),str2='po';end
        feedIt = true;
        if isfield(info.tem.(n1{1}).paths,'genCode')
            if isfield(info.tem.(n1{1}).paths.genCode,n2{1})
                if~isempty(info.tem.(n1{1}).paths.genCode.(n2{1}))
                    feedIt = true;
                end
            end
        end
        if feedIt
            info.tem.(n1{1}).paths.genCode.(n2{1})    = [info.tem.model.paths.runDir 'code' '/' str2 str1 '_' tmpStrName '.m'];
        end
    end
end
info.experiment.modelrunLogFile     =    [info.experiment.modelOutputDirPath '/' 'log_ModelRun_' tmpStrName '_runGenCode-' ...
    num2str(info.tem.model.flags.runGenCode) '_genRedMemCode-' num2str(info.tem.model.flags.genRedMemCode)...
    '_runForward-' num2str(info.tem.model.flags.runForward)   '_runOpti-' num2str(info.tem.model.flags.runOpti)...
    '.txt'];


%% convert paths in info to absolute paths
info.tem.model.paths.coreTEM           =   convertToFullPaths(info,info.tem.model.paths.coreTEM);
info.tem.model.paths.modulesDir        =   convertToFullPaths(info,info.tem.model.paths.modulesDir);

info.tem.spinup.paths.restartFile      =   convertToFullPaths(info,info.tem.spinup.paths);

%% paths of forcing
if ~isempty(info.tem.forcing.oneDataPath)
    if strcmp(strrep(getFullPath(info.tem.forcing.oneDataPath),'\','/'), strrep(info.tem.forcing.oneDataPath,'\','/'))==0
        info.tem.forcing.oneDataPath = convertToFullPaths(info,info.tem.forcing.oneDataPath);
    end
    if exist(info.tem.forcing.oneDataPath) == 0
        disp([pad('FORC PATHMISS',20) ' : ' pad('setExperimentPath',20) ' | path for one file for all forcing variables ' info.tem.forcing.oneDataPath ' does not exist!']);
    end
else
    for ii=1:numel(info.tem.forcing.variableNames)
        var_tmp = info.tem.forcing.variableNames{ii};
        pth_tmp = info.tem.forcing.variables.(var_tmp).dataPath;
        if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
            info.tem.forcing.variables.(var_tmp).dataPath = convertToFullPaths(info,pth_tmp);
            pth_tmp = info.tem.forcing.variables.(var_tmp).dataPath;
        end
        if exist(pth_tmp) == 0
            disp([pad('FORC PATHMISS',20) ' : ' pad('setExperimentPath',20) ' | path for forcing variable ' var_tmp ': ' pth_tmp ' does not exist!']);
        end
    end
end


%% paths of constraints & outDirPath of optimization
% if isfield(info,'opti')
if info.tem.model.flags.runOpti || info.tem.model.flags.calcCost
    if ~isempty(info.opti.constraints.oneDataPath)
        if strcmp(strrep(getFullPath(info.opti.constraints.oneDataPath),'\','/'), strrep(info.opti.constraints.oneDataPath,'\','/'))==0
            info.opti.constraints.oneDataPath = convertToFullPaths(info,info.opti.constraints.oneDataPath);
        end
        if exist(info.opti.constraints.oneDataPath) == 0
            disp([pad('OBS PATHMISS DAT',20) ' : ' pad('setExperimentPath',20) ' | path for one file for all observational data ' info.tem.forcing.oneDataPath ' does not exist!']);
        end
    else
        for ii=1:numel(info.opti.constraints.variableNames)
            var_tmp = info.opti.constraints.variableNames{ii};
            pth_tmp = info.opti.constraints.variables.(var_tmp).data.dataPath;
            if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
                info.opti.constraints.variables.(var_tmp).data.dataPath = convertToFullPaths(info,pth_tmp);
                pth_tmp = info.opti.constraints.variables.(var_tmp).data.dataPath;
            end
            if exist(pth_tmp) == 0
                disp([pad('OBS PATHMISS DAT',20) ' : ' pad('setExperimentPath',20) ' | path for observational variable ' var_tmp ': ' pth_tmp ' does not exist!']);
            end
            %for observational uncertainties
            if isfield(info.opti.constraints.variables.(var_tmp).unc,'dataPath')
                if isfield(info.opti.constraints.variables.(var_tmp).unc, 'dataPath') && ~isempty(info.opti.constraints.variables.(var_tmp).unc.dataPath)
                    pth_tmp = info.opti.constraints.variables.(var_tmp).unc.dataPath;
                    if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
                        info.opti.constraints.variables.(var_tmp).unc.dataPath = convertToFullPaths(info,pth_tmp);
                        pth_tmp = info.opti.constraints.variables.(var_tmp).unc.dataPath;
                    end
                    if exist(pth_tmp) == 0
                        disp([pad('OBS PATHMISS UNC',20) ' : ' pad('setExperimentPath',20) '| path for uncertainty of observational variable ' var_tmp ': ' pth_tmp ' does not exist!']);
                    end
                else
                    disp([pad('OBS VARMISS UNC',20) ' : ' pad('setExperimentPath',20) '| uncertainty data for observational ' var_tmp ' is not provided']);
                end
            else
                disp([pad('OBS PATHMISS UNC',20) ' : ' pad('setExperimentPath',20) '| the path for uncertainty data for observational ' var_tmp ' is not set']);
            end
            %for Quality Flags
            if isfield(info.opti.constraints.variables.(var_tmp),'qflag')
                if isfield(info.opti.constraints.variables.(var_tmp).qflag, 'dataPath') && ~isempty(info.opti.constraints.variables.(var_tmp).qflag.dataPath)
                    pth_tmp = info.opti.constraints.variables.(var_tmp).qflag.dataPath;
                    if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
                        info.opti.constraints.variables.(var_tmp).qflag.dataPath = convertToFullPaths(info,pth_tmp);
                        pth_tmp = info.opti.constraints.variables.(var_tmp).qflag.dataPath;
                    end
                    if exist(pth_tmp) == 0
                        disp([pad('OBS VARMISS QFLAG',20) ' : ' pad('setExperimentPath',20) '| path for quality flag of observational variable ' var_tmp ' does not exist!']);
                    end
                else
                    disp([pad('OBS PATHMISS QFLAG',20) ' : ' pad('setExperimentPath',20) '| path for quality flag of observational variable ' var_tmp ' is not set']);
                end
            end
        end
    end
end
% end

end

