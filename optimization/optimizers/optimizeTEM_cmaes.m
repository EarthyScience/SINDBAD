function [pScales]=optimizeTEM_cmaes(f,obs,info)
% A function that optimizes the TEM of SINDBAD
tic
[f,fe,fx,s,d,~,precOnceData,~,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU] = runTEM(info,f);
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f);
 fSU                                  =   prepSpinupData(f,info);

disp('TIME NEEDED FOR OPTI PRERUN')
toc
%% prepare the forcing data for spinup
defOpts                             =   info.opti.algorithm.options;
% defOpts                             =   feval(info.opti.algorithm.funHandle,'defaults',defOpts);
defOpts.LBounds                     =   eval(defOpts.LBounds)';
defOpts.UBounds                     =   eval(defOpts.UBounds)';
% info.opti.algorithm.options.pSigma     =   ones(size(info.opti.params.names));
% costhand                               =   @(pScales)calcCostTEM(pScales,f,fSU,obs,info);
% costhand                               =   @(pScales)calcCostTEM(pScales,f,precOnceData,fx,fe,d,s,dSU,sSU,fSU,obs,info);
costhand                               =   @(pScales)calcCostTEM(pScales,f,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info);



[~,~,~,~,~,pScales] = feval(info.opti.algorithm.funHandle,costhand,info.opti.params.defScalars,info.opti.algorithm.options.psigma,defOpts);

end % function