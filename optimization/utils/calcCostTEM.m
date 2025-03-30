function [cost]=calcCostTEM(pScales,f,p,precOnceData,fx,fe,d,s,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU,infoSU,obs,info)
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
%   - 1.2 on 06.11.2020 (skoirala: remove the support for returning a
%   struct for cost and handling multiobjective with an exception. That is
%   now done in the cost function.

%% scale the parameters with scalers
% NC: pScales = pScales'; % because CMAES spits outs parameter matrix PxN P paraameter vecors by N samples N = PopSize (in SDB words, gridcell)
% NC: forcing and state vars in inputs need to be of the size(pScales,1)
for i = 1:numel(info.opti.params.names)
    % NC: eval([info.opti.params.names{i} '   =   info.opti.params.defaults(i) .* pScales(:,i);'])
    eval([info.opti.params.names{i} '   =   info.opti.params.defaults(i) .* pScales(i);'])
end
%

%--> runs the model without spinup data, i.e., the empty array denotes that the spinup will be carried out in every iteration of optimization

[f,fe,fx,s,d,~,~,~,~,~,~,~,~,~]         =   runTEM(info,f,p,[],precOnceData,fx,fe,d,s,infoSU,fSU,precOnceDataSU,fxSU,feSU,dSU,sSU);

%--> calculate the cost
[cost]                              =   feval(info.opti.costFun.funHandle,f,fe,fx,s,d,p,obs,info) ;

% pScalesStr                              =   sprintf('%.4f , ' , pScales);
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Parameters: '])
paramsTable = table(info.opti.params.names, info.opti.params.defaults' .* pScales', info.opti.params.defaults', info.opti.params.lBounds', info.opti.params.uBounds', 'VariableNames',{'parameters', 'current', 'default', 'low_b', 'high_b'});
disp(paramsTable)
disp([pad(' ITER OPTI PARAM',20) ' : ' pad('calcCostTEM',20) ' | Total Cost: ' num2str(cost)])
disp(pad('+',200,'both','+'))

end
