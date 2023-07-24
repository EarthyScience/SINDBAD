export optimizeModelArray
export getSimulationDataArray, getLossArray, getLossGradient
export getDataArray, combineLossArray
export getLossVectorArray
export get_ŷ_view
export filter_common_nan

function get_ŷ_view(ŷ::AbstractArray{T,2}) where {T}
    return @view ŷ[:, 1]
end

function get_ŷ_view(ŷ::AbstractArray{T,3}) where {T}
    return @view ŷ[:, 1, :]
end

function get_ŷ_view(ŷ::AbstractArray{T,4}) where {T}
    return @view ŷ[:, 1, :, :]
end

function spatial_aggregation(y, yσ, ŷ, _, ::Val{:cat})
    return y, yσ, ŷ
end


function aggregate_data(y, yσ, ŷ, cost_option, ::Val{:timespace})
    y, yσ, ŷ = temporal_aggregation(y, yσ, ŷ, cost_option, cost_option.temporal_aggr)
    y, yσ, ŷ = spatial_aggregation(y, yσ, ŷ, cost_option, cost_option.spatial_aggr)
    return y, yσ, ŷ
end


function aggregate_data(y, yσ, ŷ, cost_option, ::Val{:spacetime})
    y, yσ, ŷ = spatial_aggregation(y, yσ, ŷ, cost_option, cost_option.spatial_aggr)
    y, yσ, ŷ = temporal_aggregation(y, yσ, ŷ, cost_option, cost_option.temporal_aggr)
    return y, yσ, ŷ
end

"""
filter_common_nan(y, yσ, ŷ)
return model and obs data filtering for the common nan
"""
function filter_common_nan(y, yσ, ŷ)
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return y[idxs], yσ[idxs], ŷ[idxs]
end

"""
getModelData(model_output::landWrapper, cost_option)
"""
function getModelData(model_output::landWrapper, cost_option)
    mod_field = cost_option.mod_field
    mod_subfield = cost_option.mod_subfield
    ŷField = getproperty(model_output, mod_field)
    ŷ = getproperty(ŷField, mod_subfield)
    return ŷ
end

"""
getModelData(model_output::AbstractArray, cost_option)
"""
function getModelData(model_output::AbstractArray, cost_option)
    return model_output[cost_option.mod_ind]
end

"""
getDataArray(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(model_output,
    observations, cost_option)
    obs_ind = cost_option.obs_ind
    ŷ = getModelData(model_output, cost_option)
    if size(ŷ, 2) == 1
        ŷ = get_ŷ_view(ŷ)
    end
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    # ymask = observations[obs_ind + 2]
    y, yσ, ŷ = aggregate_data(y, yσ, ŷ, cost_option, cost_option.aggr_order)
    # if size(ŷ) != size(y)
    #     error(
    #         "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => model and observation dimensions do not match"
    #     )
    # end
    return (y, yσ, ŷ)
end

"""
    combineLoss(lossVector, ::Val{:sum})

return the total of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:sum})
    return sum(lossVector)
end

"""
    combineLoss(lossVector, ::Val{:minimum})

return the minimum of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:minimum})
    return minimum(lossVector)
end

"""
    combineLoss(lossVector, ::Val{:maximum})

return the maximum of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:maximum})
    return maximum(lossVector)
end

"""
    combineLoss(lossVector, percentile_value)

return the percentile_value^th percentile of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(lossVector, percentile_value)
end


"""
getLossVectorArray(observations, model_output::AbstractArray, cost_options)
returns a vector of losses for variables in info.cost_options.variables_to_constrain
"""
function getLossVectorArray(observations, model_output, cost_options)
    lossVec = map(cost_options) do cost_option
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getDataArray(model_output, observations, cost_option)
        (y, yσ, ŷ) = filter_common_nan(y, yσ, ŷ)
        metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = eltype(y)(1e19)
        end
        # println("$(cost_option.variable) => $(valToSymbol(lossMetric)): $(metr)")
        metr
    end
    # println("-------------------")
    return lossVec
end


"""
filterConstraintMinimumDatapoints(obs, cost_options)
remove all the variables that have less than minimum datapoints from being used in the optimization 
"""
function filterConstraintMinimumDatapoints(obs, cost_options)
    cost_options_filtered = cost_options
    foreach(cost_options) do cost_option
        obs_ind_start = cost_option.obs_ind
        min_points = cost_option.min_data_points
        var_name = cost_option.variable
        y = obs[obs_ind_start]
        idxs = (.!isnan.(y))
        total_points = sum(idxs)
        if total_points < min_points
            cost_options_filtered = filter(row -> row.variable !== var_name, cost_options_filtered)
            @warn "$(cost_option.variable) => $(total_points) available data points < $(min_points) minimum points. Removing the constraint."
        end
    end
    return cost_options_filtered
end

"""
getLossGradient(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLossGradient(pVector::AbstractArray,
    base_models,
    forcing,
    output,
    observations,
    tblParams,
    tem,
    optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    upVector = pVector
    #newApproaches = base_models
    newApproaches = Tuple(updateModelParametersType(tblParams, base_models, upVector))
    out_d = output.data
    lopo = Tuple([lo for lo in loc_outputs])

    runEcosystem!(out_d,
        newApproaches,
        forcing,
        tem,
        loc_space_inds,
        loc_forcings,
        lopo,
        land_init_space,
        f_one)
    loss_vector = getLossVectorArray(observations, output.data, optim.cost_options)
    return combineLossArray(loss_vector, optim.multi_constraint_method)
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLossArray(pVector::AbstractArray,
    base_models,
    forcing,
    output,
    observations,
    tblParams,
    tem,
    cost_options,
    multiconstraint_method,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    upVector = pVector
    # @time begin
    newApproaches = updateModelParameters(tblParams, base_models, upVector)
    runEcosystem!(output.data,
        newApproaches,
        forcing,
        tem,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    loss_vector = getLossVectorArray(observations, output.data, cost_options)
    # end
    # println("-------------------")
    return combineLossArray(loss_vector, multiconstraint_method)
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModelArray(forcing::NamedTuple,
    output,
    observations,
    tem::NamedTuple,
    optim::NamedTuple;
    spinup_forcing=nothing)
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);

    # get the subset of parameters table that consists of only optimized parameters
    tblParams = Sindbad.getParameters(tem.models.forward,
        optim.default_parameter,
        optim.optimized_parameters)

    cost_options = filterConstraintMinimumDatapoints(observations, optim.cost_options)

    # get the default and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.default)
    lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)

    _,
    _,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    tem_with_vals,
    f_one = prepRunEcosystem(output, forcing, tem)
    cost_function =
        x -> getLossArray(x,
            tem.models.forward,
            forcing,
            output,
            observations,
            tblParams,
            tem_with_vals,
            cost_options,
            optim.multi_constraint_method,
            loc_space_inds,
            loc_forcings,
            loc_outputs,
            land_init_space,
            f_one)

    # run the optimizer
    optim_para = optimizer(cost_function,
        default_values,
        lower_bounds,
        upper_bounds,
        optim.algorithm.options,
        optim.algorithm.method)

    # update the parameter table with the optimized values
    tblParams.optim .= optim_para
    return tblParams
end
