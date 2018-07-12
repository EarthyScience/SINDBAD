function [info, obs] = prepOpti(info)
%% prepares the info.opti 
% INPUT:    info
% OUTPUT:   info, obs


% steps:
%   1) get constraints
%   2) check constraints
%   3) funHandle for cost function



%% 2) read method for optimization
%%
algorithmName                       =   info.opti.algorithm.funName;

defOptionsFilePath                      =   convertToFullPaths(info,['optimization' filesep 'algorithms' filesep algorithmName filesep 'options_' algorithmName '.json']);

try
info.opti.algorithm.options         =   readJsonFile(defOptionsFilePath);
catch
    warning(['WARN: prepOpti : optimization method : ' algorithmName ' does not have a corresponding default options file: ' defOptionsFilePath])
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
    disp(['OVWR: prepOpti : optimization method ' algorithmName ': Overwriting default options using : ' nonDefOptionsFilePath])
end

%% 3) read the cost function and options
costName                            =   info.opti.costFun.funName;
info.opti.costFun.funName           =   ['calc' costName];
defCostOptionsFilePath              =   convertToFullPaths(info,['optimization' filesep 'costFunctions' filesep costName filesep 'options_' costName '.json']);

try
    def_costOpt                    = readJsonFile(defCostOptionsFilePath);   
    info.opti.costFun.options      = def_costOpt ;
catch
    warning(['WARN: prepOpti : cost Function: ' costName ' does not have a corresponding default options file: ' defCostOptionsFilePath])
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
    disp(['OVWR: prepOpti : cost Function ' costName ': Overwriting default options using : ' nonDefCostOptionsFilePath])
end

%% create the output directory path for output files of the optimization
if isfield(info.opti.algorithm.options,'outDirPath')
    info.opti.algorithm.options.outDirPath      =   convertToFullPaths(info,[info.experiment.outputDirPath 'optimization' filesep info.opti.algorithm.options.outDirPath filesep]);
end


%% 1) create function handles and get constraints (and their uncertainties)
fun_fields = fieldnames(info.opti.constraints.funName);
for jj=1:numel(fun_fields)
    try
        info.opti.constraints.funHandle.(fun_fields{jj}) = str2func(info.opti.constraints.funName.(fun_fields{jj}));
    catch
        disp(['WARN: prepOpti: ' fun_fields{jj} ' function for reading obs. constraints is not provided: ' info.opti.constraints.funName.(fun_fields{jj})])
    end
end

obs = info.opti.constraints.funHandle.import(info);


% %read uncertainty of TWS
% try
%     info.opti.constraints.TWSobs.variableUncertainty.data.funHandle = str2func(info.opti.constraints.TWSobs.variableUncertainty.data.funName);
%     unc = info.opti.constraints.TWSobs.variableUncertainty.data.funHandle(info);
%     
%     obs.unc = unc;
%     
% catch
%     disp(['WARN: prepOpti: uncertainty function for reading obs. constraints is not provided: ' info.opti.constraints.TWSobs.variableUncertainty.data.funName])
% end


%% 2) check constraints 
% so far based checkData4TEM.m 
if isfield(info.opti.constraints.funHandle, 'check') && ~isempty(info.opti.constraints.funHandle.check)
    [info,obs] = info.opti.constraints.funHandle.check(info,obs);    
end

%% 3) create function handle for the cost function and optimizer
info.opti.costFun.funHandle             =   str2func(info.opti.costFun.funName); 
info.opti.algorithm.funHandle           =   str2func(info.opti.algorithm.funName); 

end