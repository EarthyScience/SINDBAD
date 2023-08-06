export combineLoss
export filterCommonNaN
export getData
export getLocObs!
export getLoss
export getLossVector
export getModelOutputView
export optimizeModel

function aggregateData(dat, cost_option, ::Val{:timespace})
    dat = temporalAggregation(dat, cost_option.temporal_aggregator, cost_option.temporal_aggr_type)
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_aggr)
    return dat
end

function aggregateData(dat, cost_option, ::Val{:spacetime})
    dat = spatialAggregation(dat, cost_option, cost_option.spatial_aggr)
    dat = temporalAggregation(dat, cost_option.temporal_aggregator, cost_option.temporal_aggr_type)
    return dat
end


"""
    combineLoss(lossVector, ::Val{:sum})

return the total of cost of each constraint as the overall cost
"""
function combineLoss(lossVector::AbstractArray, ::Val{:sum})
    return sum(lossVector)
end

"""
    combineLoss(lossVector, ::Val{:minimum})

return the minimum of cost of each constraint as the overall cost
"""
function combineLoss(lossVector::AbstractArray, ::Val{:minimum})
    return minimum(lossVector)
end

"""
    combineLoss(lossVector, ::Val{:maximum})

return the maximum of cost of each constraint as the overall cost
"""
function combineLoss(lossVector::AbstractArray, ::Val{:maximum})
    return maximum(lossVector)
end

"""
    combineLoss(lossVector, percentile_value)

return the percentile_value^th percentile of cost of each constraint as the overall cost
"""
function combineLoss(lossVector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(lossVector, percentile_value)
end

"""
filterCommonNaN(y, yσ, ŷ)
return model and obs data filtering for the common nan
"""
function filterCommonNaN(y, yσ, ŷ)
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return y[idxs], yσ[idxs], ŷ[idxs]
end

"""
filterConstraintMinimumDatapoints(obs_array, cost_options)
remove all the variables that have less than minimum datapoints from being used in the optimization 
"""
function filterConstraintMinimumDatapoints(obs_array, cost_options)
    cost_options_filtered = cost_options
    foreach(cost_options) do cost_option
        obs_ind_start = cost_option.obs_ind
        min_points = cost_option.min_data_points
        var_name = cost_option.variable
        y = obs_array[obs_ind_start]
        yσ = obs_array[obs_ind_start+1]
        idxs = (.!isnan.(y .* yσ))
        total_points = sum(idxs)
        if total_points < min_points
            cost_options_filtered = filter(row -> row.variable !== var_name, cost_options_filtered)
            @warn "$(cost_option.variable) => $(total_points) available data points < $(min_points) minimum points. Removing the constraint."
        end
    end
    return cost_options_filtered
end


"""
getData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(model_output,
    observations, cost_option)
    obs_ind = cost_option.obs_ind
    ŷ = getModelData(model_output, cost_option)
    if size(ŷ, 2) == 1
        ŷ = getModelOutputView(ŷ)
    end
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]
    # ymask = observations[obs_ind + 2]

    ŷ = aggregateData(ŷ, cost_option, cost_option.aggr_order)

    if cost_option.temporal_aggr_obs
        y = aggregateData(y, cost_option, cost_option.aggr_order)
        yσ = aggregateData(yσ, cost_option, cost_option.aggr_order)
    end
    return (y, yσ, ŷ)
end

@generated function getLocObs!(obs_array,
    ::Val{obs_vars},
    ::Val{s_names},
    loc_obs,
    s_locs) where {obs_vars,s_names}
    output = quote end
    foreach(obs_vars) do obsv
        push!(output.args, Expr(:(=), :d, Expr(:., :obs_array, QuoteNode(obsv))))
        s_ind = 1
        foreach(s_names) do s_name
            expr = Expr(:(=),
                :d,
                Expr(:call,
                    :view,
                    Expr(:parameters,
                        Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :s_locs, s_ind))),
                    :d))
            push!(output.args, expr)
            return s_ind += 1
        end
        return push!(output.args,
            Expr(:(=),
                :loc_obs,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :loc_obs, QuoteNode(obsv)), :d)))) #= none:1 =#
    end
    return output
end


"""
getLoss(pVector, selected_models, initOut, forcing_nt_array, observations, tbl_params, obsVariables, modelVariables)
"""
function getLoss(pVector::AbstractArray,
    base_models,
    forcing_nt_array,
    output_array,
    observations,
    tbl_params,
    tem,
    cost_options,
    multiconstraint_method,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    upVector = pVector
    updated_models = updateModelParameters(tbl_params, base_models, upVector)
    runEcosystem!(output_array,
        updated_models,
        forcing_nt_array,
        tem,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
    loss_vector = getLossVector(observations, output_array, cost_options)
    return combineLoss(loss_vector, multiconstraint_method)
end

"""
getLossVector(observations, model_output::AbstractArray, cost_options)
returns a vector of losses for variables in info.cost_options.variables_to_constrain
"""
function getLossVector(observations, model_output, cost_options)
    lossVec = map(cost_options) do cost_option
        lossMetric = cost_option.cost_metric
        (y, yσ, ŷ) = getData(model_output, observations, cost_option)
        (y, yσ, ŷ) = filterCommonNaN(y, yσ, ŷ)
        metr = loss(y, yσ, ŷ, lossMetric)
        # @time metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = oftype(metr, 1e19)
        end
        metr
    end
    # println("-------------------")
    return lossVec
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


function getModelOutputView(mod_dat::AbstractArray{T,2}) where {T}
    return @view mod_dat[:, 1]
end

function getModelOutputView(mod_dat::AbstractArray{T,3}) where {T}
    return @view mod_dat[:, 1, :]
end

function getModelOutputView(mod_dat::AbstractArray{T,4}) where {T}
    return @view mod_dat[:, 1, :, :]
end

function spatialAggregation(dat, _, ::Val{:cat})
    return dat
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModel(forcing::NamedTuple,
    observations,
    info::NamedTuple)

    tem = info.tem
    optim = info.optim
    # get the subset of parameters table that consists of only optimized parameters
    tbl_params = Sindbad.getParameters(tem.models.forward,
        optim.default_parameter,
        optim.optimized_parameters)

    cost_options = filterConstraintMinimumDatapoints(observations, optim.cost_options)

    # get the default and bounds
    default_values = tem.helpers.numbers.sNT.(tbl_params.default)
    lower_bounds = tem.helpers.numbers.sNT.(tbl_params.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tbl_params.upper)

    forcing_nt_array,
    output_array,
    _,
    _,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    tem_with_vals,
    f_one = prepRunEcosystem(forcing, info)
    cost_function =
        x -> getLoss(x,
            tem.models.forward,
            forcing_nt_array,
            output_array,
            observations,
            tbl_params,
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
    tbl_params.optim .= optim_para
    return tbl_params
end
