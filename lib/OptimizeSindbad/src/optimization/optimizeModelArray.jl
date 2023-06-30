export optimizeModelArray
export getSimulationDataArray, getLossArray, getLossGradient
export getDataArray, combineLossArray
export getLossVectorArray
export site_loss_g
export get_y, get_ŷn
"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(model_output::AbstractArray,
    observations::AbstractArray, mod_ind::Int, obs_ind_start::Int)
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
    return (y, yσ, ŷ)
end

function get_y(observations, v)
    return getproperty(observations, v)
end

function get_ŷ(outsmodel, v)
    return getproperty(outsmodel, v)
end

function get_ŷn(ŷ::AbstractArray{T,2}) where T
    return @view ŷ[:, 1]
end

function get_ŷn(ŷ::AbstractArray{T,3}) where T
    return @view ŷ[:, 1, :]
end

function get_ŷn(ŷ::AbstractArray{T,4}) where T
    return @view ŷ[:, 1, :, :]
end


"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
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

function inner_loss(y, yσ, ŷ, s_metric)
    return loss(y, yσ, ŷ, s_metric)
end

function get_trues(y, yσ, ŷ)
    return (.!isnan.(y .* yσ .* ŷ))
end

"""
getLossVector(observations::NamedTuple, tblParams::Table, optimVars::NamedTuple, optim::NamedTuple)
returns a vector of losses for variables in info.optim.variables2constrain
"""
function getLossVectorArray(observations, model_output, optim::NamedTuple)
    lossVec = map(optim.costOptions) do var_row
        lossMetric = var_row.costMetric
        obs_ind_start = var_row.obs_ind
        mod_ind = var_row.mod_ind

        (y, yσ, ŷ) = getDataArray(model_output, observations, mod_ind, obs_ind_start)

        metr = loss(y, yσ, ŷ, lossMetric)
        if isnan(metr)
            metr = eltype(y)(10)
        end
        # println("$(var_row.variable) => $(lossMetric): $(metr)")
        metr
    end
    return lossVec
end


#=
"""
getLossVector(observations::NamedTuple, tblParams::Table, optimVars::NamedTuple, optim::NamedTuple)
returns a vector of losses for variables in info.optim.variables2constrain
"""
function getLossVectorArray(observations::NamedTuple, model_output, optim::NamedTuple)
    cost_options = optim.costOptions
    #cost_options = [Pair(:gpp, Val(:mse))]
    optimVars = optim.variables.optim
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
    loss_vector = getLossVectorArray(observations, output.data, optim)
    # println("-------------------")
    return combineLossArray(loss_vector, optim.multiConstraintMethod)
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
    optim,
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
    loss_vector = getLossVectorArray(observations, output.data, optim)
    # end
    # println("-------------------")
    return combineLossArray(loss_vector, optim.multiConstraintMethod)
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

    # get the defaults and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
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
    # push!(Sindbad.error_catcher, (forcing, output, output_variables, observations, tblParams, tem, optim, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one))
    # make the cost function handle

    # output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_vals, f_one
    cost_function =
        x -> getLossArray(x,
            tem.models.forward,
            forcing,
            output,
            observations,
            tblParams,
            tem_vals,
            optim,
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
