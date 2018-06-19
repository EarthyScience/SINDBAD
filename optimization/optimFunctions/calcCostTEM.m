function [cost]=calcCostTEM(pScales,f,fSU,obs,info)
% pScales=ones(size(info.opti.params.names));
% adjust parameters
p=info.tem.params;
for i = 1:numel(info.opti.params.names)
    eval([info.opti.params.names{i} ' = ' info.opti.params.names{i} '.* pScales(i);']);
end
% runs model
[f,fe,fx,s,d,p,precOnceData,sSU,dSU] = runTEM(info,f,p,[],[],[],[],[],[],[],fSU);



%% calculate the cost 

pScales
disp(['THE COST OF THE RUN is'])
[cost]=feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info)
% cost	= info.optem.cost.function(fx,obs,info);
end % function