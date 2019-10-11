function [cost, costComps] = calcCostBaseline_weightedCF(f,fe,fx,s,d,p,obs,info)
%% weights the calcCostBaseline_Area cost function 
% based on tolerances for each constraint that are given within the extra
% settings for the cost function (extraOptions_cost.json)
% and minimum costs obtained from the single constraint optimization

%% run the baseline cost function
[~, costCompsOld] = calcCostBaseline_Area(f,fe,fx,s,d,p,obs,info);

%% weight the cost function terms 
%  minimum cost from each single constraint optimization
minCost.TWS = 0.7283;
minCost.SWE = 0.5892;
minCost.SM  = 0.1559;
minCost.ET  = 0.0946;
minCost.Q   = 0.5715;

% apply the tolerances
tolCost     = info.opti.costFun.options.Tolerances

% new cost function
costComp    = info.opti.costFun.variables2constrain;

costComps   = {};
costTotal   = 0;

for fn = 1:numel(costComp)
    cN  = costComp{fn};
    % calculate the new cost value
    costComps.(cN) = exp(log(2).*(costCompsOld.(cN)-minCost.(cN))./ tolCost.(cN));   
    % sum up the total cost
    costTotal   =   costTotal + costComps.(cN);
end



cost                 =   costTotal;
costComps.Total      =   costTotal;



end