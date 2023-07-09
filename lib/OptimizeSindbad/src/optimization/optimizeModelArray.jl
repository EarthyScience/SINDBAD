export optimizeModelArray
export getSimulationDataArray, getLossArray, getLossGradient
export getDataArray, combineLossArray
export getLossVectorArray
export site_loss_g
export get_y, get_ŷn

function get_y(observations, v)
    return getproperty(observations, v)
end

function get_ŷ(outsmodel, v)
    return getproperty(outsmodel, v)
end

function get_ŷn(ŷ::AbstractArray{T,2}) where {T}
    return @view ŷ[:, 1]
end

function get_ŷn(ŷ::AbstractArray{T,3}) where {T}
    return @view ŷ[:, 1, :]
end

function get_ŷn(ŷ::AbstractArray{T,4}) where {T}
    return @view ŷ[:, 1, :, :]
end

function spatial_aggregation(y, yσ, ŷ, _, ::Val{:cat})
    return y, yσ, ŷ
end


function aggregate_data(y, yσ, ŷ, cost_option, ::Val{:timespace})
    y, yσ, ŷ = temporal_aggregation(y, yσ, ŷ, cost_option, cost_option.temporalAggr)
    y, yσ, ŷ = spatial_aggregation(y, yσ, ŷ, cost_option, cost_option.spatialAggr)
    return y, yσ, ŷ
end


function aggregate_data(y, yσ, ŷ, cost_option, ::Val{:spacetime})
    y, yσ, ŷ = spatial_aggregation(y, yσ, ŷ, cost_option, cost_option.spatialAggr)
    y, yσ, ŷ = temporal_aggregation(y, yσ, ŷ, cost_option, cost_option.temporalAggr)
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
getDataArray(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(model_output::AbstractArray,
    observations, cost_option)
    obs_ind_start = cost_option.obs_ind
    mod_ind = cost_option.mod_ind

    ŷ = model_output[mod_ind]
    y = observations[obs_ind_start]
    yσ = observations[obs_ind_start+1]
    # ymask = observations[obs_ind_start + 2]
    if size(ŷ, 2) == 1
        if ndims(ŷ) == 3
            ŷ = @view ŷ[:, 1, :]
        elseif ndims(ŷ) == 4
            ŷ = @view ŷ[:, 1, :, :]
        else
            ŷ = @view ŷ[:, 1]
        end
    end
    y, yσ, ŷ = aggregate_data(y, yσ, ŷ, cost_option, cost_option.aggrOrder)
    # if size(ŷ) != size(y)
    #     error(
    #         "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => model and observation dimensions do not match"
    #     )
    # end
    return filter_common_nan(y, yσ, ŷ)
end

"""
getDataArray(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(model_output::AbstractArray,
    observations, mod_ind::Int, obs_ind_start::Int)
    ŷ = model_output[mod_ind]
    y = observations[obs_ind_start]
    yσ = observations[obs_ind_start+1]
    # ymask = observations[obs_ind_start + 2]
    if size(ŷ, 2) == 1
        if ndims(ŷ) == 3
            ŷ = @view ŷ[:, 1, :]
        elseif ndims(ŷ) == 4
            ŷ = @view ŷ[:, 1, :, :]
        else
            ŷ = @view ŷ[:, 1]
        end
    end

    if size(ŷ) != size(y)
        error(
            "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => model and observation dimensions do not match"
        )
    end
    return filter_common_nan(y, yσ, ŷ)
end

"""
getDataArray(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(outsmodel::landWrapper,
    observations::NamedTuple,
    obs_ind::Int,
    mod_field::Symbol,
    mod_subfield::Symbol)
    ŷField = getproperty(outsmodel, mod_field)
    ŷ = getproperty(ŷField, mod_subfield)
    if size(ŷ, 2) == 1
        if ndims(ŷ) == 3
            ŷ = @view ŷ[:, 1, :]
        elseif ndims(ŷ) == 4
            ŷ = @view ŷ[:, 1, :, :]
        else
            ŷ = @view ŷ[:, 1]
        end
    end
    y = observations[obs_ind]
    yσ = observations[obs_ind+1]

    # todo: get rid of the permutedims hack ...
    if size(ŷ) != size(y)
        error(
            "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        )
        # ŷ = y .* rand()
        # ŷ = permutedims(ŷ, (2, 3, 1))
    end
    return filter_common_nan(y, yσ, ŷ)
end


"""
getDataArray(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(outsmodel::landWrapper,
    observations::NamedTuple,
    obsV::Symbol,
    modelVarInfo::Tuple)
    ŷField = getproperty(outsmodel, modelVarInfo[1])
    ŷ = getproperty(ŷField, modelVarInfo[2])
    if size(ŷ, 2) == 1
        if ndims(ŷ) == 3
            ŷ = @view ŷ[:, 1, :]
        elseif ndims(ŷ) == 4
            ŷ = @view ŷ[:, 1, :, :]
        else
            ŷ = @view ŷ[:, 1]
        end
    end
    #@show size(ŷ)
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    # todo: get rid of the permutedims hack ...
    if size(ŷ) != size(y)
        error(
            "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        )
        # ŷ = y .* rand()
        # ŷ = permutedims(ŷ, (2, 3, 1))
    end
    return filter_common_nan(y, yσ, ŷ)
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

function inner_loss(y, yσ, ŷ, s_metric)
    return loss(y, yσ, ŷ, s_metric)
end

"""
getLossVectorArray(observations, model_output::landWrapper, cost_options)
returns a vector of losses for variables in info.cost_options.variables2constrain
"""
function getLossVectorArray(observations, model_output::landWrapper, cost_options)
    lossVec = map(cost_options) do var_row
        lossMetric = var_row.costMetric
        obs_ind = var_row.obs_ind
        mod_field = var_row.mod_field
        mod_subfield = var_row.mod_subfield
        (y, yσ, ŷ) = getDataArray(model_output, observations, obs_ind, mod_field, mod_subfield)
        # (y, yσ, ŷ) = getDataArray(model_output, observations, obsV, mod_variable)

        metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = oftype(metr, 10)
        end
        # println("$(var_row.variable) => $(valToSymbol(lossMetric)): $(metr)")
        metr
    end
    # println("-------------------")
    return lossVec
end

"""
getLossVectorArray(observations, model_output::AbstractArray, cost_options)
returns a vector of losses for variables in info.cost_options.variables2constrain
"""
function getLossVectorArray(observations, model_output::AbstractArray, cost_options)
    lossVec = map(cost_options) do var_row
        lossMetric = var_row.costMetric
        (y, yσ, ŷ) = getDataArray(model_output, observations, var_row)
        metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = eltype(y)(10)
        end
        # println("$(var_row.variable) => $(valToSymbol(lossMetric)): $(metr)")
        metr
    end
    # println("-------------------")
    return lossVec
end


#=
"""
getLossVector(observations::NamedTuple, tblParams::Table, optimVars::NamedTuple, cost_options::NamedTuple)
returns a vector of losses for variables in info.cost_options.variables2constrain
"""
function getLossVectorArray(observations::NamedTuple, model_output, cost_options::NamedTuple)
    cost_options = cost_options.costOptions
    #cost_options = [Pair(:gpp, Val(:mse))]
    optimVars = cost_options.variables.cost_options
 #   lossVec = Vector{Real}(undef, length(optimVars))
    #var_index = 1
    lossVec = map(cost_options) do p
#    for p ∈ cost_options
        obsV = first(p)
        s_metric = last(p) #var_row.costMetric
        #@code_warntype getfield(optimVars, obsV)
        #mod_variable = getfield(optimVars, obsV) #::NTuple{2,Symbol}
        #@show mod_variable
        #var_σ =  Symbol(string(obsV) * "_σ")
        #@code_warntype get_y(observations, mod_variable[2])
        y = get_y(observations, obsV)
        ŷ = model_output[1] #get_ŷ(model_output, mod_variable[2])
        ŷ = size(ŷ,2)==1 ? get_ŷn(ŷ) : ŷ
        yσ = get_y(observations, :gpp_σ)
        idxs = get_trues(y, yσ, ŷ)
        #@code_warntype loss(y, yσ, ŷ, s_metric)
        metr = loss_o(y, ŷ, s_metric, idxs)
        if isnan(metr)
           metr = oftype(metr, 1e19) # buggy?
        end
        metr
  #      lossVec[var_index] = metr 
  #      var_index += 1
    end
    return lossVec
end

=#

"""
filter_constraint_minimum_datapoints(obs, cost_options)
remove all the variables that have less than minimum datapoints from being used in the optimization 
"""
function filter_constraint_minimum_datapoints(obs, cost_options)
    cost_options_filtered = cost_options
    foreach(cost_options) do var_row
        obs_ind_start = var_row.obs_ind
        min_points = var_row.minDataPoints
        var_name = var_row.variable
        y = obs[obs_ind_start]
        idxs = (.!isnan.(y))
        total_points = sum(idxs)
        if total_points < min_points
            cost_options_filtered = filter(row -> row.variable !== var_name, cost_options_filtered)
            @warn "$(var_row.variable) => $(total_points) available data points < $(min_points) minimum points. Removing the constraint."
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
    cost_options,
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
    loss_vector = getLossVectorArray(observations, output.data, cost_options)
    return combineLossArray(loss_vector, cost_options.multiConstraintMethod)
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

    cost_options = filter_constraint_minimum_datapoints(observations, optim.costOptions)

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
    tem_vals,
    f_one = prepRunEcosystem(output, forcing, tem)
    cost_function =
        x -> getLossArray(x,
            tem.models.forward,
            forcing,
            output,
            observations,
            tblParams,
            tem_vals,
            cost_options,
            optim.multiConstraintMethod,
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
