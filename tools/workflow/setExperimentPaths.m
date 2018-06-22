function [ info ] = setExperimentPaths(info)
% Usages:
%   [info] = setExperimentPaths(info)
%
% Requires:
%   + the info:
%       ++ after reading the experiment.json file
%
% Purposes:
%   + creates the paths for model run and generated code within the info
%   based on the outputDirPath in the experiment.json
%       ++ if no/only whitespace for outputDirPath is given, a default name
%       using the experiment name, domain and runDate is defined
%       ++ if the output directory already exists, a new path using 
%       the experiment name, domain and runDate is created as subfolder

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
        outputDirPath_full = convertToFullPaths(info.experiment.outputDirPath);
    end
else
    % default output directory
    info.experiment.outputDirPath  = ['output' filesep default_tmp filesep];
    outputDirPath_full = convertToFullPaths(info.experiment.outputDirPath);
    disp(['MSG : setupTEM : no "outputDirPath" was provided : a default path is created: ' info.experiment.outputDirPath ])
end    
    
%% check if the outputDirPath already exists -> if so, rename it
ii = 0;
while exist(outputDirPath_full, 'dir')
    outputDirPath_new   = [info.experiment.outputDirPath default_tmp '_v' num2str(ii) filesep];
    outputDirPath_full  = convertToFullPaths(outputDirPath_new);
    ii = ii+1;
end

if ii > 0
    info.experiment.outputDirPath = outputDirPath_new;
    disp(['MSG : setupTEM : the outputDirPath: ' info.experiment.outputDirPath ' already exists' newline  'a default output path is created: ' outputDirPath_new  ]) 
end

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
            info.tem.(n1{1}).paths.genCode.(n2{1})	= convertToFullPaths([sindbadroot info.tem.model.paths.runDir 'code' filesep 'gen' str2 str1 '.m']);
        end
    end
end


%% convert paths in info to absolute paths
info.experiment.outputDirPath	=   outputDirPath_full;

info.tem.model.paths            =   convertToFullPaths(info.tem.model.paths);
info.tem.spinup.paths           =   convertToFullPaths(info.tem.spinup.paths);

%% set the output info.json file
if isfield(info.experiment, 'outputInfoFile')
    info.experiment.outputInfoFile(info.experiment.outputInfoFile == ' ') = [];
    if isempty(info.experiment.outputInfoFile)
        info.experiment.outputInfoFile = ['Info_' default_tmp '.json'];
    end
else
    info.experiment.outputInfoFile	=   [info.experiment.outputDirPath info.experiment.outputInfoFile]; 
end


end

