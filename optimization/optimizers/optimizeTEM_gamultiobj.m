function [optimOut]=optimizeTEM_gamultiobj(f,obs,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% run the optimization of SINDBAD parameters using gamultiobj algorithm
%
% Requires:
%   - forcing structure so that it is not loaded in every iteration
%   - observation structure to calculate cost
%   - info
%
% Purposes:
%   - returns the full output of the optimization
%
% Conventions:
%   - always needs forcing and observation
%   - the parameter scalers should always be written in pScales field of optimOut
%   - other output field names can be different
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 11.02.2020
%   - 1.1 on 27.02.2020: fixes in handling the options (skoirala)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% prepare the data for preconce and variables to pass to the optimization model run
tstart=tic;
disp(pad('-',200,'both','-'))
disp(pad('START : optimizeTEM | PREONCE RUN',200,'both',' '))
disp(pad('-',200,'both','-'))
[f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU] = runTEM(info,f);
disp([pad('TIMERUN',20) ' : ' pad(['optimizeTEM_' info.opti.algorithm.funName]) 'PREONCE RUN: Time Needed: ' sec2som(toc(tstart))])

%% prepare the options of optimization and cost function handles and call optimization
defOpts                     =   info.opti.algorithm.options;
%--> convert string fieldnames to function handles and cell arrays as needed by gamultiobj
fieldNames                  =   fieldnames(defOpts);
for fn                      =   1:numel(fieldNames)
    fName                   =   fieldNames{fn};
    valName                 =   defOpts.(fName);
    if contains(fName,'Fcn') && ~isempty(valName) 
        if startsWith(valName,'@')
            valName         =   str2func(valName);
        else
            tmp             =   eval(valName);
            valName         =   tmp{1};
        end
    end
        defOpts.(fName)     = valName;
end

%--> convert struct to name value pairs
try
    op2nameVal                  =   namedargs2cell(defOpts); % works for MATLAB 2019b onwards
catch
    op2nameVal                  =   {};
    fieldNames                  =   fieldnames(defOpts);
    for fn    = 1:numel(fieldNames)
        ind = 2*fn-1;
        op2nameVal{ind}          =   fieldNames{fn};
        op2nameVal{ind+1}       =   defOpts.(fieldNames{fn});
    end
end

%--> create the options to pass to ga
gaOptions                   =   optimoptions(@gamultiobj,op2nameVal{:});
LBounds                     =   info.opti.params.lBoundsScaled;
UBounds                     =   info.opti.params.uBoundsScaled;
costhand                            =   @(pScales)calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info);
[x,fval,exitFlag,output,population,scores]                    =    feval(info.opti.algorithm.funHandle,costhand,numel(info.opti.params.defScalars),[],[],[],[],LBounds,UBounds,gaOptions);

%% create the output structure of the full output of the optimization scheme
optimOut                                                            =   struct;
optimOut.pScales                                                    =   x;
optimOut.fval                                                       =   fval;
optimOut.exitFlag                                                   =   exitFlag;
optimOut.output                                                     =   output;
optimOut.population                                                 =   population;
optimOut.scores                                                     =   scores;
end