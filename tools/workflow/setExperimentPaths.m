function [ info ] = setExperimentPaths(info)
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
%   + Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% References:
%   +
%
% Versions:
%   + 1.0 on 22.06.2018

%% check if the experiment name, domain and runDate exist
if isfield(info.experiment, 'name')
    info.experiment.name(info.experiment.name == ' ') = [];
    name = info.experiment.name;
else
    name = 'unnamedExperiment';
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
         info.experiment.outputDirPath  = replace(info.experiment.outputDirPath,{'/','\'},filesep);
        % check whether it is an absolute path
        if strcmp(getFullPath(info.experiment.outputDirPath), info.experiment.outputDirPath)==1
            outputDirPath_full = info.experiment.outputDirPath;
        else
            outputDirPath_full = convertToFullPaths(info.experiment.outputDirPath);
        end
    else
        outputDirPath_def               = ['output' filesep default_tmp filesep];
        outputDirPath_full              = convertToFullPaths(outputDirPath_def);
        disp(['MSG : setupTEM : no "outputDirPath" was provided : a default path is created: ' outputDirPath_full  ])     
    end
else
    % default output directory
    outputDirPath_def               = ['output' filesep default_tmp filesep];
    outputDirPath_full              = convertToFullPaths(outputDirPath_def);
    disp(['MSG : setupTEM : no "outputDirPath" was provided : a default path is created: ' outputDirPath_full  ])
end



%% check if the outputDirPath already exists -> if so, rename it
ii = 0;
outputDirPath_new = outputDirPath_full;
while exist(outputDirPath_new, 'dir')
    outputDirPath_new  =    [outputDirPath_full default_tmp '_v' num2str(ii) filesep];
    ii = ii+1;
end

if ii > 0
    outputDirPath_full =    outputDirPath_new;
    default_tmp        =    [default_tmp '_v' num2str(ii)];
    disp(['MSG : setupTEM : the outputDirPath: ' info.experiment.outputDirPath ' already exists' newline  'a default output path is created: ' outputDirPath_new  ]) 
end

%% put the full outputDirPath in the info
info.experiment.outputDirPath	=   outputDirPath_full;

%% set the output info.json file -should this be a filename or absolute path?
info.experiment.outputInfoFile =    [outputDirPath_full 'Info_' default_tmp '.json'];

%% set the runDir path
info.tem.model.paths.runDir    =    info.experiment.outputDirPath;

%% set the generated code filenames into the info
% info 	= setGenCodePaths(info);
for n1 = {'model','spinup'}
    str1 = '';
    if strcmp(n1{1},'spinup'),str1='_Spinup';end
    for n2 = {'coreTEM','preCompOnce'}
        str2 = 'Core';
        if strcmp(n2{1},'preCompOnce'),str2='PrecOnce';end
        feedIt = true;
        if isfield(info.tem.(n1{1}).paths,'genCode')
            if isfield(info.tem.(n1{1}).paths.genCode,n2{1})
                if~isempty(info.tem.(n1{1}).paths.genCode.(n2{1}))
                    feedIt = true;
                end
            end
        end
        if feedIt
            info.tem.(n1{1}).paths.genCode.(n2{1})	= [info.tem.model.paths.runDir 'code' filesep 'gen' str2 str1 '.m'];
        end
    end
end


%% convert paths in info to absolute paths
info.tem.model.paths.coreTEM           =   convertToFullPaths(info.tem.model.paths.coreTEM);
info.tem.model.paths.modulesDir        =   convertToFullPaths(info.tem.model.paths.modulesDir);

info.tem.spinup.paths.restartFile      =   convertToFullPaths(info.tem.spinup.paths);

%paths of forcing
for ii=1:numel(info.tem.forcing.VariableNames)
    var_tmp = info.tem.forcing.VariableNames{ii};
    pth_tmp = info.tem.forcing.(var_tmp).DataPath;
    if exist(pth_tmp)~= 0
        if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
            info.tem.forcing.(var_tmp).DataPath = convertToFullPaths(pth_tmp);
        end
    else
        warning(['MSG: path for forcing variable ' var_tmp ': ' pth_tmp ' does not exist!']);
    end
end

%paths of constraints
if isfield(info,'opti')
    for ii=1:numel(info.opti.constraints.VariableNames)
        var_tmp = info.opti.constraints.VariableNames{ii};
        pth_tmp = info.opti.constraints.(var_tmp).DataPath;
        if exist(pth_tmp)~= 0
            if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
                info.opti.constraints.(var_tmp).DataPath = convertToFullPaths(pth_tmp);
            end
        else
            warning(['MSG: path for observational variable ' var_tmp ': ' pth_tmp ' does not exist!']);
        end
        %for observational uncertainties
        if ~isempty(info.opti.constraints.(var_tmp).VariableUncertainty.Data.DataPath)
            pth_tmp = info.opti.constraints.(var_tmp).VariableUncertainty.Data.DataPath;
            if exist(pth_tmp)~= 0
                if strcmp(strrep(getFullPath(pth_tmp),'\','/'), strrep(pth_tmp,'\','/'))==0
                    info.opti.constraints.(var_tmp).VariableUncertainty.Data.DataPath = convertToFullPaths(pth_tmp);
                end
            else
                warning(['MSG: path for uncertainty of observational variable ' var_tmp ': ' pth_tmp ' does not exist!']);
            end
        else
            disp(['MSG: no uncertainty data for observational ' var_tmp ' provided']);
        end
    end
end

end

