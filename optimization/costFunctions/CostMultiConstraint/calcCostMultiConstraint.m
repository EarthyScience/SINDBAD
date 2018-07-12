function [fullCost] = calcCostMultiConstraint(f,fe,fx,s,d,p,obs,info) 
% function [f,fe,fx,s,d,p, fullCost] = calcCostMultiConstraint(f,fe,fx,s,d,p,obs,info) 

% based on costFromFile (c) Nuno

%% transforming info.opti.costFun to needed structure
VariableNames = fieldnames(info.opti.costFun.options.components);
fx.NEE = fx.gpp - fx.cRECO;
try 
    cf = structfun(@horzcat,info.opti.costFun.options.components);
    [cf.VariableName] = VariableNames{:};   

%      [cf.VariableName] = VariableNames;%{:};   
catch
    error(['CRIT COST : calcCostMultiConstraint : Fieldnames of cost function: ' info.opti.costFun.funName ' components are not consistent (needs same fields for each variable)!'])
end

%% Stuff from Nuno.. ;)
multiFlag   = unique({cf(:).MultiConstraintMethod});

if numel(multiFlag)~=1;error('CRIT COST : calcCostMultiConstraint : MultiConstraintMethod should be unique (check cost function options)'); end

multiFlag   = multiFlag{1};

switch multiFlag
    case 'cat'  ;fullCost    = [];
    case 'mult' ;fullCost    = 1;
    case 'sum'  ;fullCost    = 0;
    otherwise
        error(['CRIT COST : calcCostMultiConstraint : not a known MultiConstraintMethod : ' cf(1).MultiConstraintMethod '(use cat, mult, or sum)'])
end

for i = 1:numel(VariableNames)
    % get data
    varName = VariableNames{i};
    obs_proc    = obs.(varName).data; 
    obs_flag    = obs.(varName).qflag; %!
    obs_unc     = obs.(varName).unc; %!
    sim_proc    = fx.(varName); %!
    
    % filter data
    ndx             = obs_flag < cf(i).minQualityFlag | obs_flag > cf(i).maxQualityFlag;
    obs_proc(ndx)   = NaN;
    obs_unc(ndx)    = NaN;
    sim_proc(ndx)   = NaN;
    if ~strcmpi(cf(i).TemporalScale,'daily')
        error(['CRIT : calcCostMultiConstraint : The function does not work for : ' cf(i).TemporalScale ' Temporal Scale'])
    end
    % compute costs
    %whos cost
    cost	= calcCVP(sim_proc,obs_proc,cf(i).CostMetric,'trim_data',cf(i).Trimming,'UncSigma',obs_unc);
%     whos cost
    %    cost=double(cost);
    cost = cost .* cf(i).CostWeight;
    
    disp(['COST : calcCostMultiConstraint : ' datestr(now) ' : mef : ' num2str(calcCVP(sim_proc,obs_proc,'mef'),'%1.14f')])
    
    switch multiFlag
        case 'cat'  ;fullCost    = [fullCost cost];
        case 'mult' ;fullCost    = fullCost .* cost;
        case 'sum'  ;fullCost    = fullCost + cost;
    end
end
% sujan
fullCost = mean(fullCost);

% disp('MSG : costFromFile : needs profiling')

end % function
