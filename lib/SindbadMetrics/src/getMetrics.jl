export combineMetric
export metricVector

"""
    combineMetric(metric_vector::AbstractArray, ::MetricSum)
    combineMetric(metric_vector::AbstractArray, ::MetricMinimum)
    combineMetric(metric_vector::AbstractArray, ::MetricMaximum)
    combineMetric(metric_vector::AbstractArray, percentile_value::T)

combines the metric from all constraints based on the type of combination.

# Arguments:
- `metric_vector`: a vector of metrices for variables

## methods for combining the metric
- `::MetricSum`: return the total sum as the metric.
- `::MetricMinimum`: return the minimum of the `metric_vector` as the metric.
- `::MetricMaximum`: return the maximum of the `metric_vector` as the metric.
- `percentile_value::T`: `percentile_value^th` percentile of metric of each constraint as the overall metric

"""
function combineMetric end
function combineMetric(metric_vector::AbstractArray, ::MetricSum)
    return sum(metric_vector)
end

function combineMetric(metric_vector::AbstractArray, ::MetricMinimum)
    return minimum(metric_vector)
end

function combineMetric(metric_vector::AbstractArray, ::MetricMaximum)
    return maximum(metric_vector)
end

function combineMetric(metric_vector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(metric_vector, percentile_value)
end



"""
    metricVector(model_output::LandWrapper, observations, cost_options)
    metricVector(model_output, observations, cost_options)
   
returns a vector of metrics for variables in info.cost_options.observational_constraints   

# Arguments:
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `model_output`: a collection of SINDBAD model output time series as a time series of stacked land NT
- `cost_options`: a table listing each observation constraint and how it should be used to calculate the loss/metric of model performance    
"""
metricVector

function metricVector(model_output, observations, cost_options)
    loss_vector = map(cost_options) do cost_option
        @debug "***cost for $(cost_option.variable)***"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        @debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ)
        # (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ, cost_option.valids)
        metr = metric(y, yσ, ŷ, lossMetric) * cost_option.cost_weight
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        @debug "$(cost_option.variable) => $(nameof(typeof(lossMetric))): $(metr)"
        metr
    end
    @debug "\n-------------------\n"
    return loss_vector
end

function metricVector(model_output::LandWrapper, observations, cost_options)
    loss_vector = map(cost_options) do cost_option
        @debug "$(cost_option.variable)"
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        @debug "size y, yσ, ŷ", size(y), size(yσ), size(ŷ), size(idxs)
        (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ) ## cannot use the valids because LandWrapper produces vector
        metr = metric(y, yσ, ŷ, lossMetric) * cost_option.cost_weight
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        @debug "$(cost_option.variable) => $(nameof(typeof(lossMetric))): $(metr)"
        metr
    end
    @debug "\n-------------------\n"
    return loss_vector
end

