function [optimOut]=optimizeTEM_cmaes(f,obs,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% run the optimization of SINDBAD parameters using CMAES algorithm
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
%   - 1.0 on 17.01.2019 
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
defOpts                                             =   info.opti.algorithm.options;
defOpts.LBounds                                     =   eval(defOpts.LBounds)';
defOpts.UBounds                                     =   eval(defOpts.UBounds)';
costhand                                            =   @(pScales)calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info);
[xmin,fmin,counteval,stopflag,out,bestever]         =   feval(info.opti.algorithm.funHandle,costhand,info.opti.params.defScalars,info.opti.algorithm.options.psigma,defOpts);

%% create the output structure of the full output of the optimization scheme
optimOut                                            =   struct;
optimOut.xmin                                       =   xmin;               % xmin in the last iteration
optimOut.fmin                                       =   fmin;               % function value of xmin in the last iteration
optimOut.counteval                                  =   counteval;          % number of function evaluations done
optimOut.stopflag                                   =   stopflag;           % stop criterion reached
optimOut.out                                        =   out;                % struct with various histories and solutions
optimOut.pScales                                    =   bestever.x;         % scalar for bestever solution 
optimOut.bestever                                   =   bestever;           % structure with bestever solution 

end