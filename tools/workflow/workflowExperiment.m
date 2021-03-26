function [f,fe,fx,s,d,p,precOnceData,info,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU,obs,cost] = workflowExperiment(expConfigFile,varargin)
% Runs a SINDBAD model experiment with either a given experimental config or info
%
% Requires:
%    - a configuration file for an experiment or
%    - an info structure
%
% Purposes:
%   - runs the experiment based on the configuration files or info
%       - in different modes such as forward or optimization
%   - in v1.1: 
%       - forward run with cost calculation but without
%         optimization
%       - outputs additionally the observational constraints
%         and costs
%   - in v1.2:
%       - possible to save output if input is an info structure
%   - in v1.3:
%       - possible to do simulations per year
%   - in v1.4:
%       - read and use parameter values defined in a .json file
%
% Conventions:
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - v1.1: Tina Trautmann (ttraut)
%   - v1.2: Tina Trautmann (ttraut)
%   - v1.3: Sujan Koirala (skoirala)
%   - v1.4: Tina Trautmann (ttraut) 
%   - v1.5: Sujan Koirala 
%   - v1.6: Sujan Koirala 
%   - v1.7: Sujan Koirala 
%
% References:
%
% Versions:
%   - 1.7 on 11.02.2020 (finding parameter set with minimum squared distance in
%                       multiobj)
%   - 1.6 on 11.02.2020 (handling of full optimization output)
%   - 1.5 on 10.11.2019 (handling of writing output)
%   - 1.4 on 09.01.2019
%   - 1.3 on 20.12.2018
%   - 1.2 on 20.08.2018
%   - 1.1 on 18.07.2018 
%   - 1.0 on 01.07.2018

%% 
%% ------------------------------------------------------------------------
% create a temporary log file
% -------------------------------------------------------------------------
% resetPath

tstartwf = tic;
tmpStrDate                          =   datestr(now,30);
tmpLogFile                          =   ['Log_SINDBAD_run_' tmpStrDate(1:end-7) '_' num2str(randi([1 100000],1)) '.txt'];
if exist(tmpLogFile,'file') == 2
    eval(['delete ' tmpLogFile])
end
diary(tmpLogFile)

% start log file content
disp(pad('-',200,'both','-'))
disp(pad('START: Log of SINDBAD model experiment',200,'both'))
disp(pad('-',200,'both','-'))
% end log file content

%% ------------------------------------------------------------------------
% check if the experiment configuration has been passed, stop if not
% -------------------------------------------------------------------------

if ~exist('expConfigFile','var')
    dispMSG = [pad('CRIT WORKFLOW',20) ' : ' pad('workflowExperiment',20) ' | Cannot run an experiment without configuration file [expConfigFile(.json)] or SINDBAD info'];
    disp(dispMSG)
    diary
    error(dispMSG)
end

%% ------------------------------------------------------------------------
% setup the TEM
% -------------------------------------------------------------------------

% start log file content
disp(pad('-',200,'both','-'))
disp(pad('Set up the TEM of SINDBAD',200,'both',' '))
disp(pad('-',200,'both','-'))
% end log file content

[info, expConfigFile]                       =   setupTEM(expConfigFile,varargin{:});

%% ----------------------------------------------------------------------------------------------------------
% include changes from command line in info & setup the optimization if it's on or if costs shall be computed
% -----------------------------------------------------------------------------------------------------------
% change the commanline options before settings up the code
% [info]                                  =   editTEMInfo(info,varargin{:});

if info.tem.model.flags.runOpti || info.tem.model.flags.calcCost
    
    % start log file content
    disp(pad('-',200,'both','-'))
    disp(pad('Set up the optimization of SINDBAD',200,'both',' '))
    disp(pad('-',200,'both','-'))
    % end log file content
    
    [info]                                  =   setupOpti(info);
    [info]                                  =   editTEMInfo(info,varargin{:});
    infoLite                                =   info;
    [info, obs]                             =   prepOpti(info);
    
else
    [info]                                  =   editTEMInfo(info,varargin{:});
    infoLite                                =   info;
end

%% ------------------------------------------------------------------------
% prepare the SINDBAD objects and structures
% -------------------------------------------------------------------------

% start log file content
disp(pad('-',200,'both','-'))
disp(pad('Prepare the objects and structure of SINDBAD',200,'both',' '))
disp(pad('-',200,'both','-'))
% end log file content

% get the parameter values in the wanted precision

p           =   info.tem.params;
paramType   =  'default'; % comes from info


% get the full table of all parameters
paramStruct = getParamsStruct(info);

%% ------------------------------------------------------------------------
% Forward run the model when optimization is off
% -------------------------------------------------------------------------

if info.tem.model.flags.runForward && ~info.tem.model.flags.runOpti
    
    % do simulations per year
    if info.tem.model.flags.runForwardYearly
        sYear=info.tem.model.time.sYear;
        eYear=info.tem.model.time.eYear;
        for runYear=sYear:eYear
            info.tem.model.time.runYear=runYear;
            [f,fe,fx,s,d,info]                          =   prepTEM(info);
            if runYear == sYear
                [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU]    =   runTEM(info,f,p);
                info.tem.spinup.flags.runSpinup = 0;
                SUData.sSU = s;
                SUData.dSU = d;
            else
                [f,fe,fx,s,d,info]                      =   prepTEM(info);
                [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU]    =   runTEM(info,f,p,SUData);
            end
            [~]                                         =   writeOutput(info,f,fe,fx,s,d,p);
        end
        
        % do simulations for entire time series
    else     
        [f,fe,fx,s,d,info]                              =   prepTEM(info);        
        % start log file content
        disp(pad('-',200,'both','-'))
        disp(pad(['Forward run SINDBAD model with ' paramType ' parameters'],200,'both',' '))
        disp(pad('-',200,'both','-'))
        % end log file content        
        [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU]    =   runTEM(info,f,p,[],[],fx,fe,d,s);
        [~]                                                                         =   writeOutput(info,f,fe,fx,s,d,p);
    end
    
end


%% ----------------------------------------------------------------------------------------
% Optimize the model and then do the forward run using optimized parameter when opti is on
% -----------------------------------------------------------------------------------------

if info.tem.model.flags.runOpti
    [f,fe,fx,s,d,info]                      =   prepTEM(info);
    
    % start log file content
    disp(pad('-',200,'both','-'))
    disp(pad('optimizing the SINDBAD TEM',200,'both',' '))
    disp(pad('-',200,'both','-'))
    % end log file content
    
    % function handle for optimization
    if isempty(info.opti.optimizer.funName)
        optimizerFunName                        =   ['optimizeTEM_' info.opti.algorithm.funName];
    else
        optimizerFunName = info.opti.optimizer.funName;
    end
    optimizerFunHandle                      =   str2func(optimizerFunName);
    
    % evaluate the optimization
    [optimOutFull]                          =   feval(optimizerFunHandle,f,obs,info);
    % get the optimized parameter values into p
    pScales                                 =   optimOutFull.pScales;
    % for multiobjective optimization, save the parameter with minimum
    % sum of distance to minimum for each objective
    if info.opti.algorithm.isMultiObj
        pScalesFull                         =   optimOutFull.pScales;
        fVals                               =   optimOutFull.fval;
        fValsSqDis                          =   (fVals - min(fVals,1)) .^ 2;
        [~,fValsSqDisInd]                   =   min(sqrt(sum(fValsSqDis,2)));
        pScales                             =   pScalesFull(fValsSqDisInd,:);
    end
    
    for i                                   =   1:numel(info.opti.params.names)
        eval([info.opti.params.names{i} '   = info.opti.params.defaults(i) .* pScales(i);'])
    end
    
    % save the optimized parameters as a json
    [paramFile] = saveOptimizedParams(info, p);
    disp([pad('optimized parameter values are saved in a .json file',30) ' : ' paramFile])
    % save the full optimization results
    save(info.opti.paths.outFullPath, 'optimOutFull', '-v7.3')
    disp(pad(['saved full optimization output to : ' info.opti.paths.outFullPath],200))
    
    % start log file content
    disp(pad('-',200,'both','-'))
    disp(pad('Forward run SINDBAD model with optimized parameters',200,'both',' '))
    disp(pad('-',200,'both','-'))
    % end log file content
    
    % forward run with optimized parameter values
    [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU]    =   runTEM(info,f,p);
    [~]                                                                         =   writeOutput(info,f,fe,fx,s,d,p);
    
end

% save the full table of the parameters
[~]=saveParamsTable(info, p, paramStruct);
%% ------------------------------------------------------------------------
% Calculate the cost
% -------------------------------------------------------------------------
if info.tem.model.flags.calcCost || info.tem.model.flags.runOpti
    [cost]  =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;

    disp([pad(' FORWARD RUN COST',20) ' : ' pad(info.opti.costFun.funName,20) ' | Algorithm: ' info.opti.algorithm.funName ' | Cost: '])
    if info.opti.algorithm.isMultiObj
        constraint = info.opti.variables2constrain;
        cost       = round(cost(:),2);
        disp(table(constraint, cost))
    else
        cost       = round(cost(:),2);
        disp(cost)
    end
    disp(pad('+',200,'both','+'))
else
    cost    = {};
    obs     = {}; 
end
%% ------------------------------------------------------------------------
% Save the data and model output
% -------------------------------------------------------------------------

% start log file content
disp(pad('-',200,'both','-'))
disp(pad('Save the data',200,'both',' '))
disp(pad('-',200,'both','-'))
% end log file content

% create a copy of the configuration files of the experimentment to output directory
if ~isstruct(expConfigFile) 
    [pth,~,~] = fileparts(expConfigFile);
else % info structure was input, use path of modelRun.json
    [pth,~,~] = fileparts(info.experiment.configFiles.modelRun);
end
copyfile(pth,info.experiment.settingsOutputDirPath);
disp(pad(['copy of configuration files : ' info.experiment.settingsOutputDirPath],200))

% save the light version of info with all configs and settings as a json file
% Tina hack to not save info if its the input to the workflow
if ~isstruct(expConfigFile)
    savejsonJL('',infoLite,info.experiment.outputInfoFile);
    disp(pad(['light version of info (.json)' ' : ' info.experiment.outputInfoFile],100))
else
    expConfigFile = 'info structure input';
    disp(pad('info (.json) not saved',200))
end

% save the info as mat file
save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate '_info.mat'], 'info', '-v7.3')
disp(pad(['saved full version of info (.mat) to : ' info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate '_info.mat'],200))

% % save the f as mat file
% save([info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate  '_f.mat'], 'f', '-v7.3')
% disp([pad('forcing data (.mat)',30) ' : ' info.experiment.modelOutputDirPath info.experiment.name '_' info.experiment.runDate  '_f.mat'])

%% ------------------------------------------------------------------------------------------
% write the experiment information and move the temporary log file to model output directory
% -------------------------------------------------------------------------------------------

% start log file content
disp(pad('-',200,'both','-'))
disp(pad(['EXPERIMENT COMPLETE: ' info.experiment.name ' with following configuration'],200,'both'))
disp(pad('-',200,'both','-'))
% kind of model run

if info.tem.model.flags.runOpti
    disp(pad('Model Run in Optimization Mode',200,'both','-'))
elseif info.tem.model.flags.calcCost
    disp(pad('Model Run in Forward Mode & Cost calculation (without Optimization)',200,'both','-'))
else
    disp(pad('Model Run in Forward Mode (without Optimization)',200,'both','-'))
end

% kind of code used
if info.tem.model.flags.runGenCode
    disp(pad('Model Run using Generated Code',200,'both','-'))
else
    disp(pad('Model Run using Original Handles',200,'both','-'))
end
if info.tem.model.flags.genRedMemCode
    disp(pad('Memory Reduction through genRedMemCode = 1',200,'both','-'))
else
    disp(pad('No Memory Reduction through genRedMemCode',200,'both','-'))
end

% list of configuration files
disp(pad('List of used Configuration Files',200,'both','-'))

disp([pad('experiment',20) ' : ' expConfigFile])
confFN = fields(info.experiment.configFiles) ;
for cfn = 1:numel(confFN)
    if ~strcmp(confFN{cfn},'opti')
        disp([pad(confFN{cfn},20) ' : ' info.experiment.configFiles.(confFN{cfn})])
    end
end
if info.tem.model.flags.runOpti
    disp(pad('Optimization Configuration:',200,'both','-'))
    disp([pad('Main Configuration',35) ' : ' info.experiment.configFiles.opti])
    disp([pad('Optimization Algorithm',35) ' : ' info.opti.algorithm.funName])
    disp([pad('Optimization Additional Options',35) ' : ' info.opti.algorithm.nonDefOptFile])
    disp([pad('Cost Function Name',35) ' : ' info.opti.costFun.funName])
    disp([pad('Cost Function Additional Options',35) ' : ' info.opti.costFun.nonDefOptFile])
    
end

if info.tem.model.flags.calcCost
    disp(pad('Cost Configuration:',200,'both','-'))
    disp([pad('Cost Function defined through',35) ' : ' info.experiment.configFiles.opti])
    disp([pad('Cost Function Name',35) ' : ' info.opti.costFun.funName])
    disp([pad('Cost Function Additional Options',35) ' : ' info.opti.costFun.nonDefOptFile])

end

% total time needed
disp(pad('-',200,'both','-'))

disp(['  TOTAL TIME | Experiment:               ' info.experiment.name ' | ' sec2som(toc(tstartwf))])

disp(pad('-',200,'both','-'))
disp(pad('END: Log of SINDBAD model experiment',200,'both'))
disp(pad('-',200,'both','-'))

% end log file content

diary
movefile(tmpLogFile,info.experiment.modelrunLogFile)
end
