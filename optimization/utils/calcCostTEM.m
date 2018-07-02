function [cost]=calcCostTEM(pScales,f,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info)
% pScales,f,precOnceData,fx,fe,d,s,dSU,sSU,fSU,obs,info
% function [cost]=calcCostTEM(pScales,f,fSU,obs,info)

% pScales=ones(size(info.opti.params.names));
% adjust parameters
%%
p=info.tem.params;

for i = 1:numel(info.opti.params.names)
    eval([info.opti.params.names{i} ' = info.opti.params.defaults(i) .* pScales(i);'])
%     info.opti.params.names{i}
%     eval(info.opti.params.names{i})
%     eval([info.opti.params.names{i} ' = ' info.opti.params.names{i} '.* pScales(i);']);
end
% runs model

tstart = tic;
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
% [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU] = runTEM(info,f);


% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
[f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],[],fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p);
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,[],fSU,[],[],[],dSU,sSU);

disp(['    TIME : calcCostTEM with [ runTEM(info,f,p,[],[],fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU) ]: iteration time: ' sec2som(toc(tstart))])


% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,[],[],[],[],[],[],[],fSU);



%% calculate the cost 

disp(['    PARAM : calcCostTEM: Parameter Scalars of the iteration: ' string(pScales)])
[cost]  =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
disp(['    COST : calcCostTEM: cost of current iteration: ' num2str(cost)])
end % function