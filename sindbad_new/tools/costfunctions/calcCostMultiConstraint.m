function [f,fe,fx,s,d,p, fullCost] = calcCostMultiConstraint(f,fe,fx,s,d,p,obs,info) 

% based on costFromFile (c) Nuno

%% transforming info.opti.costFun to needed structure
VariableNames = fieldnames(info.opti.costFun.(info.opti.costFun.costName).components);

try 
    cf = structfun(@horzcat,info.opti.costFun.(info.opti.costFun.costName));
    [cf.VariableName] = VariableNames{:};   
catch
    error(['ERR : costFromFile : Fieldnames of cost function: ' info.opti.costFun.costName ' components are not consistent!'])
end

%% Stuff from Nuno.. ;)
multiFlag   = unique({cf(:).MultiConstraintMethod});

if numel(multiFlag)~=1;error('ERR : costFromFile : MultiConstraintMethod should be unique'); end

multiFlag   = multiFlag{1};

switch multiFlag
    case 'cat'  ;fullCost    = [];
    case 'mult' ;fullCost    = 1;
    case 'sum'  ;fullCost    = 0;
    otherwise
        error(['ERR : costFromFile : not a known MultiConstraintMethod : ' cf(1).MultiConstraintMethod])
end

for i = 1:numel(cf)
    % get data
    obs_proc    = obs.(cf(i).VariableName); 
    obs_flag    = obs.flag.([cf(i).VariableName]); %!
    obs_unc     = obs.unc.([cf(i).VariableName]); %!
    sim_proc    = fx.(cf(i).VariableName); %!
    
    % filter data
    ndx             = obs_flag < cf(i).minQualityFlag | obs_flag > cf(i).maxQualityFlag;
    obs_proc(ndx)   = NaN;
    obs_unc(ndx)    = NaN;
    sim_proc(ndx)   = NaN;
    if ~strcmpi(cf(i).TemporalScale,'daily')
        error(['ERR : costFromFile : not prepared for TemporalScale : ' cf(i).TemporalScale])
    end
    % compute costs
    %whos cost
    cost	= calc_cvp(sim_proc,obs_proc,cf(i).CostMetric,'trim_data',cf(i).Trimming,'UncSigma',obs_unc);
    whos cost
    %    cost=double(cost);
    cost = cost .* cf(i).CostWeight;
    
    disp(['MSG : costFromFile : ' datestr(now) ' : mef : ' num2str(calc_cvp(sim_proc,obs_proc,'mef'),'%1.14f')])
    
    switch multiFlag
        case 'cat'  ;fullCost    = [fullCost cost];
        case 'mult' ;fullCost    = fullCost .* cost;
        case 'sum'  ;fullCost    = fullCost + cost;
    end
end

disp('MSG : costFromFile : needs profiling')

end % function
