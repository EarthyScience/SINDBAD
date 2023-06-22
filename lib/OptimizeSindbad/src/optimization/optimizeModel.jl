export optimizeModel
export getSimulationData, loss, getLoss
export getData
export mapOptimizeModel
export getLossVector

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(outsmodel::NamedTuple, observations::NamedTuple, obsV::Symbol, modelVarInfo::Tuple)
    ŷ = getproperty(outsmodel, modelVarInfo[2])
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    # todo: get rid of the permutedims hack ... should come from input/observation data, which should have dimensions in time, lat, lon or depth, time, lat, lon
    if size(ŷ) != size(y)
        @warn "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        ŷ = permutedims(ŷ, (2, 3, 1))
    end
    #@show size(y[:]), size(yσ[:]), size(ŷ)
    return (y[:], yσ[:], ŷ)
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(outsmodel::landWrapper,
    observations::NamedTuple,
    obsV::Symbol,
    modelVarInfo::Tuple)
    ŷField = getproperty(outsmodel, modelVarInfo[1])
    ŷ = getproperty(ŷField, modelVarInfo[2])
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    # todo: get rid of the permutedims hack ...
    if size(ŷ) != size(y)
        @warn "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        ŷ = permutedims(ŷ, (2, 3, 1))
    end
    return (y, yσ, ŷ)
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
getLossVector(observations::NamedTuple, tblParams::Table, optimVars::NamedTuple, optim::NamedTuple)
returns a vector of losses for variables in info.optim.variables2constrain
"""
function getLossVector(observations::NamedTuple, model_output, optim::NamedTuple)
    lossVec = []
    cost_options = optim.costOptions
    optimVars = optim.variables.optim
    for var_row ∈ cost_options
        obsV = var_row.variable
        lossMetric = var_row.costMetric
        mod_variable = getfield(optimVars, obsV)
        (y, yσ, ŷ) = getData(model_output, observations, obsV, mod_variable)
        metr = loss(y, yσ, ŷ, Val(lossMetric))
        if isnan(metr)
            push!(lossVec, 1.0E19)
        else
            push!(lossVec, metr)
        end
        #@info "$(obsV) => $(lossMetric): $(metr)"
    end
    return lossVec
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLoss(pVector::AbstractArray,
    forcing::NamedTuple,
    spinup_forcing::Any,
    initOut::NamedTuple,
    observations::NamedTuple,
    tblParams::Table,
    tem::NamedTuple,
    optim::NamedTuple)
    newApproaches = updateModelParameters(tblParams, tem.models.forward)
    outevolution = runEcosystem(newApproaches, forcing, initOut, tem; spinup_forcing=spinup_forcing) # spinup + forward run!
    @info ".........................................."
    loss_vector = getLossVector(observations, outevolution, optim)
    @info "-------------------"

    return combineLoss(loss_vector, Val(optim.multiConstraintMethod))
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModel(forcing::NamedTuple,
    initOut::NamedTuple,
    observations::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple;
    spinup_forcing=nothing)
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);

    # get the subset of parameters table that consists of only optimized parameters
    tblParams = getParameters(tem.models.forward, optim.optimized_parameters)

    # get the defaults and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
    lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)

    # make the cost function handle
    cost_function =
        x -> getLoss(x, forcing, spinup_forcing, initOut, observations, tblParams, tem,
            optim)

    # run the optimizer
    optim_para = optimizer(cost_function,
        default_values,
        lower_bounds,
        upper_bounds,
        optim.algorithm.options,
        Val(optim.algorithm.method))

    # update the parameter table with the optimized values
    tblParams.optim .= optim_para
    return tblParams
end

function unpackYaxOpti(args; forcing_variables::AbstractArray)
    nforc = length(forcing_variables)
    outputs = first(args)
    forcings = args[2:(nforc+1)]
    observations = args[(nforc+2):end]
    return outputs, forcings, observations
end

function doOptimizeModel(args...;
    out::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    forcing_variables::AbstractArray,
    obs_variables::AbstractArray,
    spinup_forcing::Any)
    output, forcing, observation = unpackYaxOpti(args; forcing_variables)
    forcing = (; Pair.(forcing_variables, forcing)...)
    observation = (; Pair.(obs_variables, observation)...)
    params = optimizeModel(forcing, out, observation, tem, optim; spinup_forcing=spinup_forcing)
    return output[:] = params.optim
end

function mapOptimizeModel(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    optim::NamedTuple,
    observations::NamedTuple,
    ;
    spinup_forcing=nothing,
    max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_variables = collect(forcing.variables)
    outdims = output.paramdims
    out = output.land_init
    obs_variables = collect(observations.variables)

    params = mapCube(doOptimizeModel,
        (incubes...,);
        out=out,
        tem=tem,
        optim=optim,
        forcing_variables=forcing_variables,
        obs_variables=obs_variables,
        spinup_forcing=spinup_forcing,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache)
    return params
end
