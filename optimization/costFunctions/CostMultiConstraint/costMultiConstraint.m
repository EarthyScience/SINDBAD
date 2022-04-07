function [cost] = costMultiConstraint(f,fe,fx,s,d,p,obs,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% function to calculate the cost of a model simulation
%
% Requires:
%   - forcing structure so that it is not loaded in every iteration
%   - observation structure to calculate cost
%   - info
%
% Purposes:
%   - returns the full output of the optimization
%
% Conventions:
%   - always needs forcing and observation
%   - the parameter scalers should always be written in pScales field of optimOut
%   - other output field names can be different
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 09.11.2020
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%
% get the varaibles to optimize
VariableNames = info.opti.variables2constrain;

% force the multiconstraint/variable cost to return an array when a
% multiobjective method is run
multiConstraintMethod = info.opti.costFun.multiConstraintMethod;
if info.opti.algorithm.isMultiObj
    multiConstraintMethod = 'cat';
end
    
% define cost array
fullCost    = [];
    
% get cost metric function handle
metric_fun          = info.opti.costMetric.funHandle;
    
cmList = {};
% loop through the variables
for i = 1:numel(VariableNames)
    varName             = VariableNames{i};
    trimPerc            = info.opti.constraints.variables.(varName).costOptions.trimPerc;
    costMetric          = info.opti.constraints.variables.(varName).costOptions.costMetric;
    aggrOrder           = info.opti.constraints.variables.(varName).costOptions.aggrOrder;
    spatialAggr         = info.opti.constraints.variables.(varName).costOptions.spatialAggr;
    spatialCostAggr     = info.opti.constraints.variables.(varName).costOptions.spatialCostAggr;
    timeAggrFreq        = info.opti.constraints.variables.(varName).costOptions.temporalAggr;
    timeAggrFunc        = info.opti.constraints.variables.(varName).costOptions.temporalAggrFunc;
    timeAggrObs         = info.opti.constraints.variables.(varName).costOptions.temporalAggrObs;
    costWeight          = info.opti.constraints.variables.(varName).costOptions.costWeight;
    areaWeight          = info.opti.constraints.variables.(varName).costOptions.areaWeight;
    quality_bound       = info.opti.constraints.variables.(varName).costOptions.quality_bound;
    data_bound          = info.opti.constraints.variables.(varName).costOptions.data_bound;
    
    cmList{end+1} = costMetric;
    % set the CostMetric to the same size array as the number of pixels.
    % Used when the cost is calculated separately for each pixel using
    % table and rowfun
    costMetric     = num2cell(repmat(costMetric,info.tem.helpers.sizes.nPix,1),2);
    if isnumeric(spatialCostAggr)
        spatialCostAggr_per = spatialCostAggr;
        spatialCostAggr     = 'percentile';
    end
    
    % get the observation data and it's uncertainty
    obs_proc    = obs.(varName).data;
    if isfield(obs.(varName), 'unc')
        obs_unc     = obs.(varName).unc; %!
    else
        obs_unc= obs_proc;
    end
    
    % get the simulation data and set it to sim_proc. The modelFullVar
    % includes the operators so that any mean/median/extraction can be
    % correctly applied.
    modVar              = info.opti.constraints.variables.(varName).modelFullVar;
    evalStr             = ['sim_proc = ' modVar ';'];
    eval(evalStr)
    if info.tem.helpers.sizes.nPix == 1 && size(sim_proc,1) > 1
        sim_proc = sim_proc';
    end
    
    % apply the the nan mask of observation to simulation
    ndx             = isnan(obs_proc);
    obs_proc(ndx)   = NaN;
    obs_unc(ndx)    = NaN;
    sim_proc(ndx)   = NaN;
    % apply the quality flag and filter data based on observation/user
    % input
    % apply quality flag bounds
    if ~isempty(quality_bound) && isfield(obs.(varName), 'qflag')
        obs_flag        = obs.(varName).qflag; %!
        ndx             = obs_flag < quality_bound(1) | obs_flag > quality_bound(2);
        obs_proc(ndx)   = NaN;
        obs_unc(ndx)    = NaN;
        sim_proc(ndx)   = NaN;
    end
    
    % remove the tail percentiles of observation (across all grids)
    if isnumeric(trimPerc) && ~isempty(trimPerc)
        percLow         = prctile(obs_proc, trimPerc(1));
        percHigh        = prctile(obs_proc, trimPerc(2));
        ndx             = obs_proc < percLow | obs_proc > percHigh;
        obs_proc(ndx)   = NaN;
        obs_unc(ndx)    = NaN;
        sim_proc(ndx)   = NaN;
    end
    
    % remove the data outside the given bounds of observation (across all
    % grids)
    if ~isempty(data_bound)
        ndx             = obs_proc < data_bound(1) | obs_proc > data_bound(2);
            obs_proc(ndx)   = NaN;
            obs_unc(ndx)    = NaN;
            sim_proc(ndx)   = NaN;
            end
    
    % apply area weight/grid area and calculate mean. The areaWeight can be
    % 0 for false and 1 for true
    if areaWeight > 0
        datSizeTime_obs = size(obs_proc, 2);
        datSizeTime_sim = size(sim_proc, 2);
        gridArea_obs    = repmat(info.tem.helpers.dimension.space.areaPix,1,datSizeTime_obs);
        gridArea_sim    = repmat(info.tem.helpers.dimension.space.areaPix,1,datSizeTime_sim);
        obs_proc        = obs_proc .* gridArea_obs;
        obs_unc         = obs_unc .* gridArea_obs;
        sim_proc        = sim_proc .* gridArea_sim;
    end
    
    % do the spatiotemporal agrregation
    switch aggrOrder
        case 'spacetime'
            % space first and time second
            [sim_proc, obs_proc, obs_unc]   = spatial_aggregation(sim_proc, obs_proc, obs_unc, spatialAggr);
            [sim_proc, obs_proc, obs_unc]   = temporal_aggregation(sim_proc, obs_proc, obs_unc, timeAggrFreq, timeAggrFunc, timeAggrObs, info);
        case 'timespace'
            % time first and space second
            [sim_proc, obs_proc, obs_unc]   = temporal_aggregation(sim_proc, obs_proc, obs_unc, timeAggrFreq, timeAggrFunc, timeAggrObs, info);
            [sim_proc, obs_proc, obs_unc]   = spatial_aggregation(sim_proc, obs_proc, obs_unc, spatialAggr);
        otherwise
            error(['CRIT : costMultiConstraint : The function does not work for : ' aggrOrder ' order of space and time aggregation aggregation of data. Use either {spacetime, timespace}.'])
        end
    
        
    % compute costs either for all grid cells or per grid cell with summary
    % statistics as cost
        
    switch spatialCostAggr
        case 'cat'
            cost        =   metric_fun({sim_proc(:)}, {obs_proc(:)}, costMetric,{obs_unc(:)});
        case 'mean'
            dataTab     =   table(num2cell(sim_proc,2), num2cell(obs_proc,2), costMetric, num2cell(obs_unc,2), 'VariableNames',{'sim_proc', 'obs_proc', 'costMetric', 'obs_unc'});
            cost_full   =   rowfun(metric_fun, dataTab, 'OutputVariableName','cost');
            cost        =   nanmean(cost_full.cost);
        case 'median'
            dataTab     =   table(num2cell(sim_proc,2), num2cell(obs_proc,2), costMetric, num2cell(obs_unc,2),'VariableNames',{'sim_proc', 'obs_proc', 'costMetric', 'obs_unc'});
            cost_full   =   rowfun(metric_fun, dataTab, 'OutputVariableName','cost');
            cost        =   nanmedian(cost_full.cost);
        case 'percentile'
            dataTab     =   table(num2cell(sim_proc,2), num2cell(obs_proc,2), costMetric, num2cell(obs_unc,2),'VariableNames',{'sim_proc', 'obs_proc', 'costMetric', 'obs_unc'});
            cost_full   =   rowfun(metric_fun, dataTab, 'OutputVariableName','cost');
            cost        =   prctile(cost_full.cost, spatialCostAggr_per);
        otherwise
            error(['CRIT : costMultiConstraint : The function does not work for : ' spatialCostAggr ' spatial aggregation of cost. Use either {cat, mean, median, or a numeric value for percentile}.'])
    end
    
    % apply weighht for cost
%     varName

    cost        = cost .* costWeight;
    if isinf(cost)
        fullCost    = [fullCost 1e15];
    else
        fullCost    = [fullCost cost];
        end
    end
disp([pad(' ITER OPTI COST',20) ' : ' pad('costMultiConstraint',20) ' | Cost components: '])
costTable = table(VariableNames, cmList', fullCost','VariableNames',{'constraint', 'metric', 'cost'});
disp(costTable)
    
% combine/produce the different method for putting the cost together
switch multiConstraintMethod
    case 'cat'
        cost            =   fullCost;
    case 'mult'
        cost        = prod(fullCost);
    case 'sum'
        cost        = nansum(fullCost);
    case 'min'
        cost        = nanmin(fullCost);
    case 'max'
        cost        = nanmax(fullCost);
    otherwise
        error(['CRIT : costMultiConstraint : The function does not work for : ' multiConstraintMethod ' multiConstraintMethod. Use either {cat, min, max, mult, sum}.'])
end

% spatial aggregation function
    function [sim_proc, obs_proc, obs_unc] = spatial_aggregation(sim_proc_in, obs_proc_in, obs_unc_in, spatialAggr_in)
        switch spatialAggr_in
            case 'cat'
                sim_proc    = sim_proc_in;
                obs_proc    = obs_proc_in;
                obs_unc     = obs_unc_in;
            case 'mean'
                sim_proc    = nanmean(sim_proc_in, 1);
                obs_proc    = nanmean(obs_proc_in, 1);
                obs_unc     = nanmean(obs_unc_in, 1);
            case 'sum'
                sim_proc    = nansum(sim_proc_in, 1);
                obs_proc    = nansum(obs_proc_in, 1);
                obs_unc     = nansum(obs_unc_in, 1);
            case 'median'
                sim_proc    = nanmedian(sim_proc_in, 1);
                obs_proc    = nanmedian(obs_proc_in, 1);
                obs_unc     = nanmedian(obs_unc_in, 1);
            otherwise
                error(['CRIT : costMultiConstraint : The function does not work for : ' spatialAggr_in ' spatial aggregation/operation of data. Use either {cat, mean, median, sum}.'])
        end
    end
    
    
% temporal aggregation/operation of the simulation (and observation)
    function [sim_proc, obs_proc, obs_unc]  = temporal_aggregation(sim_proc_in, obs_proc_in, obs_unc_in, timeAggrFreq_in, timeAggrFunc_in, timeAggrObs_in, info_in)
        if ~timeAggrObs_in
            obs_proc                        = obs_proc_in;
            obs_unc                         = obs_unc_in;
        end
        switch timeAggrFreq_in
            case 'mean'
                sim_proc                    = nanmean(sim_proc_in, 2);
                if timeAggrObs_in
                    obs_proc                = nanmean(obs_proc_in, 2);
                    obs_unc                 = nanmean(obs_unc_in, 2);
                end
            case 'day'
                sim_proc                    = sim_proc_in;
                if timeAggrObs_in
                    obs_proc                = obs_proc_in;
                    obs_unc                 = obs_unc_in;
                end
            case {'month', 'year'}
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                sim_proc                    = temporalAggr(sim_proc_in, days_v, timeAggrFreq_in, timeAggrFunc_in);
                if timeAggrObs_in
                    obs_proc                = temporalAggr(obs_proc_in, days_v, timeAggrFreq_in, timeAggrFunc_in);
                    obs_unc                 = temporalAggr(obs_unc_in, days_v, timeAggrFreq_in, timeAggrFunc_in);
                end
            case 'dayAnomaly'
                sim_proc                    = sim_proc_in - mean(sim_proc_in, 2);
                if timeAggrObs_in
                    obs_proc                = obs_proc_in - mean(obs_proc_in, 2);
                    obs_unc                 = obs_unc_in - mean(obs_unc_in, 2);
                end
            case 'dayMSC'
                sim_proc                    = getForcingMSC(sim_proc_in,info_in.tem.helpers.dates.year,info_in);
                if timeAggrObs_in
                    obs_proc                = getForcingMSC(obs_proc_in,info_in.tem.helpers.dates.year,info_in);
                    obs_unc                 = getForcingMSC(obs_unc_in,info_in.tem.helpers.dates.year,info_in);
                end
            case 'dayMSCAnomaly'
                sim_proc                    = getForcingMSC(sim_proc_in,info_in.tem.helpers.dates.year,info_in);
                sim_proc                    = sim_proc - mean(sim_proc, 2);
                if timeAggrObs_in
                    obs_proc                = getForcingMSC(obs_proc_in,info_in.tem.helpers.dates.year,info_in);
                    obs_proc                = obs_proc - mean(obs_proc, 2);
                    obs_unc                 = getForcingMSC(obs_unc_in,info_in.tem.helpers.dates.year,info_in);
                    obs_unc                 = obs_unc - mean(obs_proc, 2);
                end
            case {'monthAnomaly'}
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                mod_month                   = temporalAggr(sim_proc_in, days_v, 'month', timeAggrFunc_in);
                sim_proc                    = mod_month - mean(mod_month, 2);
                if timeAggrObs_in
                    obs_proc_month          = temporalAggr(obs_proc_in, days_v, 'month', timeAggrFunc_in);
                    obs_proc                = obs_proc_month - mean(obs_proc_month, 2);
                    obs_unc_month           = temporalAggr(obs_unc_in, days_v, 'month', timeAggrFunc_in);
                    obs_unc                 = obs_unc_month - mean(obs_unc_month, 2);
                end
            case 'monthIAV'
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                [mod_month, mons_v]         = temporalAggr(sim_proc_in, days_v, 'month', timeAggrFunc_in);
                mons_v                      = month(mons_v);
                [~, ~, sim_proc, ~]         = calcMSC(mod_month, mons_v);
                if timeAggrObs_in
                    obs_proc_month          = temporalAggr(obs_proc_in, days_v, 'month', timeAggrFunc_in);
                    [~, ~, obs_proc, ~]     = calcMSC(obs_proc_month, mons_v);
                    obs_unc_month           = temporalAggr(obs_unc_in, days_v, 'month', timeAggrFunc_in);
                    [~, ~, obs_unc, ~]      = calcMSC(obs_unc_month, mons_v);
                end
            case 'monthMSC'
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                [mod_month, mons_v]         = temporalAggr(sim_proc_in, days_v, 'month', timeAggrFunc_in);
                mons_v                      = month(mons_v);
                [sim_proc, ~, ~, ~ ]        = calcMSC(mod_month, mons_v);
                if timeAggrObs_in
                    obs_proc_month          = temporalAggr(obs_proc_in, days_v, 'month', timeAggrFunc_in);
                    [obs_proc, ~, ~, ~]     = calcMSC(obs_proc_month, mons_v);
                    obs_unc_month           = temporalAggr(obs_unc_in, days_v, 'month', timeAggrFunc_in);
                    [obs_unc, ~, ~, ~]      = calcMSC(obs_unc_month, mons_v);
                end
            case 'monthMSCAnomaly'
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                [mod_month, mons_v]         = temporalAggr(sim_proc_in, days_v, 'month', timeAggrFunc_in);
                mons_v                      = month(mons_v);
                [sim_proc, ~, ~, ~]         = calcMSC(mod_month, mons_v);
                sim_proc                    = sim_proc - mean(sim_proc, 2);
                if timeAggrObs_in
                    obs_proc_month          = temporalAggr(obs_proc_in, days_v, 'month', timeAggrFunc_in);
                    [obs_proc, ~, ~, ~]     = calcMSC(obs_proc_month, mons_v);
                    obs_proc                = obs_proc - mean(obs_proc, 2);
                    obs_unc_month           = temporalAggr(obs_unc_in, days_v, 'month', timeAggrFunc_in);
                    [obs_unc, ~, ~, ~]      = calcMSC(obs_unc_month, mons_v);
                    obs_unc                 = obs_unc - mean(obs_unc, 2);
                end
            case {'yearAnomaly'}
                days_v                      = datenum(info_in.tem.helpers.dates.day);
                mod_year                    = temporalAggr(sim_proc_in, days_v, 'year', timeAggrFunc_in);
                sim_proc                    = mod_year - mean(mod_year, 2);
                if timeAggrObs_in
                    obs_proc_year           = temporalAggr(obs_proc_in, days_v, 'year', timeAggrFunc_in);
                    obs_proc                = obs_proc_year - mean(obs_proc_year, 2);
                    obs_unc_year            = temporalAggr(obs_unc_in, days_v, 'year', timeAggrFunc_in);
                    obs_unc                 = obs_unc_year - mean(obs_unc_year, 2);
                end
            otherwise
                error(['CRIT : costMultiConstraint : The function does not work for : ' timeAggrFreq_in ' temporal aggregation/operation yet. Use either {mean, day, month, year, dayAnomaly, dayMSC, dayMSCAnomaly, monthAnomaly, monthIAV, monthMSC, monthMSCAnomaly, yearAnomaly}.'])
        end
    end
    
end
