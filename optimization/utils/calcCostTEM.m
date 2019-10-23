function [cost, costComp]=calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info)
% pScales,f,precOnceData,fx,fe,d,s,dSU,sSU,fSU,obs,info
% function [cost]=calcCostTEM(pScales,f,fSU,obs,info)

% pScales=ones(size(info.opti.params.names));
% adjust parameters
%%
% p=info.tem.params;

for i = 1:numel(info.opti.params.names)
    eval([info.opti.params.names{i} ' = info.opti.params.defaults(i) .* pScales(i);'])
%     info.opti.params.names{i}
%      eval(info.opti.params.names{i})
%     pScales(i)
%     eval([info.opti.params.names{i} ' = ' info.opti.params.names{i} '.* pScales(i);']);
end
% runs model
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,SUData,precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU)
% [f,fe,fx,s,d,p,precOnceData,fSU,feSU,fxSU,sSU,dSU,precOnceDataSU] = runTEM(info,f);


% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],[],fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
[f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],[],fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);
% [f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p);
% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,[],fSU,[],[],[],dSU,sSU);

% disp(['    TIME : calcCostTEM with [ runTEM(info,f,p,[],[],fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU) ]: iteration time: ' sec2som(toc(tstart))])


% [f,fe,fx,s,d,p,precOnceData,sSU,dSU]  = runTEM(info,f,p,[],[],[],[],[],[],[],fSU);



%% calculate the cost 
pScalesStr = sprintf('%.4f , ' , pScales);
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Parameter Scalars of the iteration: ' pScalesStr(1:end-2)])
try
    [cost, costComp]  =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
    
    if isfield(info.opti.algorithm.options, 'isMultiObj')
        compN    = info.opti.costFun.variables2constrain;
        cost        = NaN(1,numel(compN));
        for cn = 1:numel(compN)
            cost(1,cn) = costComp.(compN{cn});
        end
    end 
    cost
    
catch
[cost]  =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
    costComp = 0;
end


disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Cost of current iteration: ' num2str(cost)])
disp(pad('+',200,'both','+'))

end % function
