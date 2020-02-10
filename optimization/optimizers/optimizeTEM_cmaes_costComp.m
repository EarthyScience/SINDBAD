function [pScales]=optimizeTEM_cmaes_costComp(f,obs,info)
% A function that optimizes the TEM of SINDBAD
tstart=tic;
disp(pad('-',200,'both','-'))
disp(pad('START : optimizeTEM | PREONCE RUN',200,'both',' '))
disp(pad('-',200,'both','-'))
[f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU,infoSU] = runTEM(info,f);

disp([pad('TIMERUN',20) ' : ' pad(['optimizeTEM_' info.opti.algorithm.funName]) 'PREONCE RUN: Time Needed: ' sec2som(toc(tstart))])

%% prepare the forcing data for spinup
defOpts                             =   info.opti.algorithm.options;
defOpts.LBounds                     =   eval(defOpts.LBounds)';
defOpts.UBounds                     =   eval(defOpts.UBounds)';
costhand                               =   @(pScales)calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info);


[~,~,~,~,~,pScales] = feval(info.opti.algorithm.funHandle,costhand,info.opti.params.defScalars,info.opti.algorithm.options.psigma,defOpts);

end