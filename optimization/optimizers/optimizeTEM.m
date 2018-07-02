function [pScales]=optimizeTEM(f,obs,info)
% A function that optimizes the TEM of SINDBAD
%% prepare the spinip data to avoid repetition in optimization iteration
fSU                                 =   prepSpinupData(f,info);

%% prepare the forcing data for spinup
% defOpts                             =   info.opti.algorithm.options;
% % defOpts=struct;
% % defOpts                             =   feval(info.opti.algorithm.funHandle,'defaults',defOpts);
% defOpts.LBounds                     =   eval(defOpts.LBounds)';
% defOpts.UBounds                     =   eval(defOpts.UBounds)';
% info.opti.method.options.pSigma     =   ones(size(info.opti.params.names));
costhand                               =   @(pScales)calcCostTEM(pScales,f,fSU,obs,info);



% [pScales,~,~,~,~,~] = cmaes(fhand,info.opti.params.defScalars,info.opti.method.options.pSigma,defOpts);
[pScales,~,~,~,~,~] = feval(info.opti.algorithm.funHandle,costhand,info.opti.params.defScalars);
% [pScales,~,~,~,~,~] = cmaes('calcCostTEM(pScales,f,obs,info)',info.opti.params.defScalars,[],defOpts);
% [pScales,~,~,~,~,~] = cmaes('calcCostTEM(pScales,f,obs,info)',info.opti.params.defScalars,[],defOpts);
% [pScales,~,~,~,~,~] = feval(info.opti.method.funHandle,fhand,info.opti.params.defScalars,[],defOpts);

end % function