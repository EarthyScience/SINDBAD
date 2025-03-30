function [cost, costComp]=calcCostTEM_VEG(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info)
% calculates the cost(s) for a given set of parameter values 
%
% Requires:
%   - The parameter scalers that are applied to default parameter values
%   - SINDBAD structures that are needed to execute runTEM
%
% Purposes:
%   - returns the cost (and components of it) for a single model run. 
%
% Conventions:
%   - the cost function can only have one or two output variables
%   - if one, it should be the total cost (scalar)
%   - if two, it should be the total cost (scalar), and a struct with its components      
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 17.01.2019 
%   - 1.1 on 01.05.2019 (by ttraut: handling cost functions which return individual cost compoents)

%% scale the parameters with scalers
for i = 1:numel(info.opti.params.names)
    eval([info.opti.params.names{i} '   =   info.opti.params.defaults(i) .* pScales(i);'])
end
%

%--> runs the model without spinup data, i.e., the empty array denotes that the spinup will be carried out in every iteration of optimization

[f,fe,fx,s,d,~,~,~,~,~,~,~,~,~]         =   runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);

%% alternatively
% [costF]                    =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
% if info.opti.algorithm.isMultiObj
%     compN                           =   info.opti.costFun.variables2constrain;
%     cost                            =   NaN(1,numel(compN));
%     for cn                          =   1:numel(compN)
%         cost(1,cn)                  =   costF.(compN{cn});
%     end
% else
%     cost=costF.Total
% end 
% %%
% if  info.tem.model.flags.runForward && info.tem.model.flags.calcCost
%     cost=costF
% end

%--> calculate the cost from the model output

try
    % if cost function returns both total cost and its components
    [cost, costComp]                    =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
    
    if info.opti.algorithm.isMultiObj
        compN                           =   info.opti.variables2constrain;
        cost                            =   NaN(1,numel(compN));
        for cn                          =   1:numel(compN)
            cost(1,cn)                  =   costComp.(compN{cn});
        end
    end 
    
catch
    % if cost function only returns total cost
    [cost]                              =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;
    costComp                            =   0;
end


pScalesStr                              =   sprintf('%.4f , ' , pScales);
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Parameter Scalars of current iteration: ' pScalesStr(1:end-2)])
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Cost of current iteration: ' num2str(cost)])
disp(pad('+',200,'both','+'))

end
