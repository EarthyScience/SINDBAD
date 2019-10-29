function [cost, costComp]=calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info)
% run the model and calculate the cost for a given parameter set
% recurrent. Never published, but very similar to Lardy et al 200?
%
% Requires:
%	- all SINDBAD structure + NI2E = number of iterations to equilibrium
%
% Purposes:
%   - Returns the model C pools in equilibrium
%
% Conventions:
%
% Created by:
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%
% Notes:
%   - the input datasets [f,fe,fx,s,d] have to have a full year (or cycle
%   of years) that will be used as the recycling dataset for the
%   determination of C pools at equilibrium
%   - for model structures that loop the carbon cycle between pools this is
%   merely a rough approximation (the solution does not really work...)
%
% Versions:
%   - 1.0 on 01.05.2018
%   - 1.1 on 29.10.2019: fixed the wrong removal of a dimension by squeeze on
%   Bt and At when nPix == 1 (single point simulation)
%%


    %%
% p=info.tem.params;

for i = 1:numel(info.opti.params.names)
    eval([info.opti.params.names{i} ' = info.opti.params.defaults(i) .* pScales(i);'])
end
% runs model
[f,fe,fx,s,d,~,~,~,~,~,~,~,~]  = runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);


%% calculate the cost 
pScalesStr = sprintf('%.4f , ' , pScales);
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Parameter Scalars of the iteration: ' pScalesStr(1:end-2)])
try
    [cost, costComp]    =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
    
    if isfield(info.opti.algorithm.options, 'isMultiObj')
        compN           =   info.opti.costFun.variables2constrain;
        cost            =   NaN(1,numel(compN));
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
