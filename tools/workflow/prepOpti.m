function [info, obs] = prepOpti(info)
% Prepares the information and data needed for optimization
%
% Requires:
%    - info with the name of the algorithm and cost function
%   - variables and path for observational constraints and (associated)
%   uncertainties
%
% Purposes:
%   - fills the information of optimization algorithm and cost in the fields of info.opti.
%   - puts the observational data of constraints in obs structure
%
% Conventions:
%   - all information related to optimization goes to info.opti
%   - all observational variable goes to the fields of obs
%       - the fieldnames should have the same variable name as SINDBAD
%       (e.g., obs.gpp obs.wSnow
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 01.07.2018

%% read the information related to optimization algorithm
algorithmName                       =   info.opti.algorithm.funName;

defOptionsFilePath                  =   convertToFullPaths(info,['optimization' '/' 'algorithms' '/' algorithmName '/' 'options_' algorithmName '.json']);

try
info.opti.algorithm.options         =   readJsonFile(defOptionsFilePath);
catch
    disp([pad('WARN OPTI ALGO',20) ' : ' pad('prepOpti',20) ' | ' pad('optimization method',20) ' | ' pad(algorithmName,20) ' does not have a corresponding default options file: ' defOptionsFilePath])
end
%--> Overwrite the default options when non-default options are provided
nonDefOptionsFile   = info.opti.algorithm.nonDefOptFile;
if ~isempty(nonDefOptionsFile)
    nonDefOptionsFilePath           =   convertToFullPaths(info,nonDefOptionsFile);
    nonDefOptions                   =   readJsonFile(nonDefOptionsFilePath);
    fNamesND                        =   fields(nonDefOptions);
    for fnInd = 1:numel(fNamesND)
        fName = char(fNamesND(fnInd));
        info.opti.algorithm.options.(fName) = nonDefOptions.(fName);
    end
    info.opti.algorithm.nonDefOptFile = nonDefOptionsFilePath;
    disp([pad('OVWR OPTI ALGO',20) ' : ' pad('prepOpti',20) ' | ' pad('optimization method',20) ' : ' pad(algorithmName,20) ' | Overwriting default options using : ' nonDefOptionsFilePath])
end

%% read the information related to cost function
costName                            =   info.opti.costFun.funName;
defCostOptionsFilePath              =   convertToFullPaths(info,['optimization' '/' 'costFunctions' '/' costName '/' 'options_' costName '.json']);

try
    def_costOpt                     =   readJsonFile(defCostOptionsFilePath);   
    info.opti.costFun.options       =   def_costOpt ;
catch
    disp([pad('WARN OPTI COST',20) ' : ' pad('prepOpti',20) ' | ' pad('cost function',20) ' | ' pad(costName,20) ' does not have a corresponding default options file: ' defCostOptionsFilePath])
end
%--> Overwrite the default options when non-default options are provided
nonDefCostOptionsFile   = info.opti.costFun.nonDefOptFile;
if ~isempty(nonDefCostOptionsFile)
    nonDefCostOptionsFilePath           =   convertToFullPaths(info,nonDefCostOptionsFile);
    nonDefCostOptions                   =   readJsonFile(nonDefCostOptionsFilePath);
    fNamesNDCost                        =   fields(nonDefCostOptions);
    for fnIndC = 1:numel(fNamesNDCost)
        fNameC = char(fNamesNDCost(fnIndC));
        info.opti.costFun.options.(fNameC) = nonDefCostOptions.(fNameC);
    end
    info.opti.costFun.nonDefOptFile     = nonDefCostOptionsFilePath;
    disp([pad('OVWR OPTI COST',20) ' : ' pad('prepOpti',20) ' | ' pad('cost function',20) ' : ' pad(costName,20) ' | Overwriting default options using : ' nonDefCostOptionsFilePath])
end

%% create the output directory path for output files of the optimization algorithm
if isfield(info.opti.algorithm.options,'outDirPath')
    info.opti.paths.outDirPath              =   convertToFullPaths(info,[info.experiment.outputDirPath 'optimization' '/' info.opti.algorithm.options.outDirPath '/']);
    info.opti.algorithm.options.outDirPath  =   info.opti.paths.outDirPath;
else
    info.opti.paths.outDirPath      =   convertToFullPaths(info,[info.experiment.outputDirPath 'optimization' '/']);    
end
mkdirx(info.opti.paths.outDirPath);
info.opti.paths.ParamFilePath         =   [info.opti.paths.outDirPath '../optimizedParams' '_' info.experiment.domain '_' info.opti.algorithm.funName '_' info.experiment.name '.json'];

info.opti.paths.ParamTablePath         =   [info.opti.paths.outDirPath '../table_Params' '_' info.experiment.domain '_' info.opti.algorithm.funName '_' info.experiment.name '.xlsx'];

info.opti.paths.outFullPath         =   [info.opti.paths.outDirPath 'optimResultsFull' '_' info.experiment.domain '_' info.opti.algorithm.funName '_' info.experiment.name '.mat'];
%% 1) create the function handles and get constraints for optimization
fun_fields = fieldnames(info.opti.constraints.funName);
for jj=1:numel(fun_fields)
    try
        info.opti.constraints.funHandle.(fun_fields{jj}) = str2func(info.opti.constraints.funName.(fun_fields{jj}));
    catch
        disp([pad('WARN OBS FUNC',20) ' : ' pad('prepOpti',20) ' | ' pad(fun_fields{jj},20) ' | function for reading obs. constraints is not provided: ' info.opti.constraints.funName.(fun_fields{jj})])
    end
end

obs = info.opti.constraints.funHandle.import(info);


%% run the checks on the observational data
% so far based checkData4TEM.m 
if isfield(info.opti.constraints.funHandle, 'check') && ~isempty(info.opti.constraints.funHandle.check)
    [info,obs] = info.opti.constraints.funHandle.check(info,obs);    
end

%% create function handles for the optimization algorithm and cost function
info.opti.costFun.funHandle             =   str2func(info.opti.costFun.funName); 
info.opti.algorithm.funHandle           =   str2func(info.opti.algorithm.funName); 

%% create metric function handle to enable having a user-defined performance metric file  -OUTCOMMENTED TINA
if isfield(info.opti, 'costMetric')
fullMetricPath        = getFullPath([sindbadroot info.opti.costMetric.funName]);
[~,~,fileEnd] = fileparts(fullMetricPath);
if isempty(fileEnd)
    perfMetricFile = [fullMetricPath '.m'];
else
    perfMetricFile = fullMetricPath;
end
[perfMetricDir,perfMetricFile,~]  = fileparts(perfMetricFile);
oldDir = pwd;
cd(perfMetricDir);
info.opti.costMetric.funHandle = str2func(perfMetricFile);
cd(oldDir);
end

%% add scaled parameter bounds
info.opti.params.uBoundsScaled  = info.opti.params.uBounds  ./ info.opti.params.defaults ;
info.opti.params.lBoundsScaled  = info.opti.params.lBounds  ./ info.opti.params.defaults ;
info.opti.params.defScalars     = info.opti.params.defaults  ./ info.opti.params.defaults ;

end
