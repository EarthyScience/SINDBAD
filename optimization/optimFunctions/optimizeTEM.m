function [pScales]=optimizeTEM(f,obs,info)
% a function to optimize tem
%% prepare the spinip data to avoid repetition in optimization iteration
fSU	= prepSpinupData(f,info);

%% prepare the forcing data for spinup
defOpts=info.opti.method.options;
% defOpts=struct;
defOpts=feval(info.opti.method.funHandle,'defaults',defOpts);
defOpts.LBounds=eval(defOpts.LBounds)';
defOpts.UBounds=eval(defOpts.UBounds)';
info.opti.method.options.pSigma=ones(size(info.opti.params.names));
fhand=@(pScales)calcCostTEM(pScales,f,fSU,obs,info);



% [pScales,~,~,~,~,~] = cmaes(fhand,info.opti.params.defScalars,info.opti.method.options.pSigma,defOpts);
[pScales,~,~,~,~,~] = feval(info.opti.method.funHandle,fhand,info.opti.params.defScalars,info.opti.method.options.pSigma,defOpts);
% [pScales,~,~,~,~,~] = cmaes('calcCostTEM(pScales,f,obs,info)',info.opti.params.defScalars,[],defOpts);
% [pScales,~,~,~,~,~] = cmaes('calcCostTEM(pScales,f,obs,info)',info.opti.params.defScalars,[],defOpts);
% [pScales,~,~,~,~,~] = feval(info.opti.method.funHandle,fhand,info.opti.params.defScalars,[],defOpts);

end % function