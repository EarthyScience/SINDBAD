export optimizeModel, getParameters, updateParameters
export getConstraintNames, getSimulationData, loss, getLoss
export getData
export mapOptimizeModel

"""
getParameters(selectedModels)
retrieve all models parameters
"""
function getParameters(selectedModels)
    defaults = [flatten(selectedModels)...]
    constrains = metaflatten(selectedModels, Models.bounds)
    nbounds = length(constrains)
    lower = [constrains[i][1] for i in 1:nbounds]
    upper = [constrains[i][2] for i in 1:nbounds]
    names = [fieldnameflatten(selectedModels)...] # SVector(flatten(x))
    modelsApproach = [parentnameflatten(selectedModels)...]
    models = [Symbol(supertype(getproperty(Models, m))) for m in modelsApproach]
    varsModels = [join((models[i], names[i]), ".") for i in 1:nbounds]
    return Table(; names, defaults, optim=defaults, lower, upper, modelsApproach, models, varsModels)
end

"""
getParameters(selectedModels, listParams)
retrieve all selected models parameters
"""
function getParameters(selectedModels, listParams)
    paramstbl = getParameters(selectedModels)
    return filter(row -> row.names in listParams, paramstbl)
end

"""
getParameters(selectedModels, listParams, listModels)
retrieve all selected models parameters by model
"""
function getParameters(selectedModels, listParams, listModels)
    paramstbl = getParameters(selectedModels)
    return filter(row -> row.names in listParams && row.models in listModels, paramstbl)
end

"""
getParameters(selectedModels, listModelsParams::Vector{String})
retrieve all selected models parameters from string input
"""
function getParameters(selectedModels, listModelsParams::Vector{String})
    paramstbl = getParameters(selectedModels)
    return filter(row -> row.varsModels in listModelsParams, paramstbl)
end

"""
updateParameters(tblParams, approaches)
"""
function updateParameters(tblParams::Table, approaches::Tuple)
    function filtervar(var, modelName, tblParams, approachx)
        subtbl = filter(row -> row.names == var && row.modelsApproach == modelName, tblParams)
        if isempty(subtbl)
            return getproperty(approachx, var)
        else
            return subtbl.optim[1]
        end
    end
    updatedModels = Models.LandEcosystem[]
    namesApproaches = nameof.(typeof.(approaches)) # a better way to do this?
    for (idx, modelName) in enumerate(namesApproaches)
        approachx = approaches[idx]
        newapproachx = if modelName in tblParams.modelsApproach
            vars = propertynames(approachx)
            newvals = Pair[]
            for var in vars
                inOptim = filtervar(var, modelName, tblParams, approachx)
                #TODO Check whether this works correctly
                push!(newvals, var => inOptim)
            end
            typeof(approachx)(; newvals...)
        else
            approachx
        end
        push!(updatedModels, newapproachx)
    end
    return (updatedModels...,)
end

"""
    getConstraintNames(info)
returns
- obsVariables: a list of observation variables that will be used to calculate cost
- optimVariables: a dictionary of model variables (with land subfields and sub-sub fields) to compare against the observations
- storeVariables: a dictionary of model variables for which the time series will be stored in memory after the forward run
"""
function getConstraintNames(optim::NamedTuple)
    obsVariables = Symbol.(optim.variables2constrain)
    modelVariables = String[]
    optimVariables = (;)
    for v in obsVariables
        vinfo = getproperty(optim.constraints.variables, v)
        push!(modelVariables, vinfo.modelFullVar)
        vf, vvar = Symbol.(split(vinfo.modelFullVar, "."))
        optimVariables = setTupleField(optimVariables, (v, tuple(vf, vvar)))
    end
    # optimVariables = getVariableGroups(modelVariables)
    storeVariables = getVariableGroups(modelVariables)
    return obsVariables, optimVariables, storeVariables
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(outsmodel::NamedTuple, observations::NamedTuple, obsV::Symbol, modelVarInfo::Tuple)
    ŷ =  getproperty(outsmodel, modelVarInfo[2])
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    return (y, yσ, ŷ)
end
"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(outsmodel::landWrapper, observations::NamedTuple, obsV::Symbol, modelVarInfo::Tuple)
    ŷField = getproperty(outsmodel, modelVarInfo[1])
    ŷ = getproperty(ŷField, modelVarInfo[2])
    #...)' |> Matrix |> vec
    # ŷField = getproperty(outsmodel, modelVarInfo[1]).evap
    # ŷ = hcat(getproperty(ŷField, modelVarInfo[2])...)' |> Matrix |> vec
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
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
    for var_row in cost_options
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
        @info "$(obsV) => $(lossMetric): $(metr)"
    end
    return lossVec
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLoss(pVector::AbstractArray, forcing::NamedTuple, spinup_forcing::Any, initOut::NamedTuple,
    observations::NamedTuple, tblParams::Table, tem::NamedTuple, optim::NamedTuple)
    # tblParams.optim .= pVector # update the parameters with pVector
    # @show pVector, typeof(pVector)
    if eltype(pVector) <: ForwardDiff.Dual
        tblParams.optim .= [tem.helpers.numbers.sNT(ForwardDiff.value(v)) for v ∈ pVector] # update the parameters with pVector
    else
        tblParams.optim .= pVector # update the parameters with pVector
    end

    newApproaches = updateParameters(tblParams, tem.models.forward)
    outevolution = runEcosystem(newApproaches, forcing, initOut, tem; spinup_forcing=spinup_forcing) # spinup + forward run!
    @info ".........................................."
    loss_vector = getLossVector(observations, outevolution, optim)
    @info "-------------------"

    return combineLoss(loss_vector, Val(optim.multiConstraintMethod))
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModel(forcing::NamedTuple, initOut::NamedTuple, observations::NamedTuple,
    tem::NamedTuple, optim::NamedTuple; spinup_forcing=nothing)
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);

    # get the subset of parameters table that consists of only optimized parameters
    tblParams = getParameters(tem.models.forward, optim.optimized_parameters)

    # get the defaults and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
    lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)

    # make the cost function handle
    cost_function = x -> getLoss(x, forcing, spinup_forcing, initOut,
        observations, tblParams, tem, optim)

    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, optim.algorithm.options, Val(optim.algorithm.method))

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


function doOptimizeModel(args...; out::NamedTuple, tem::NamedTuple, optim::NamedTuple, forcing_variables::AbstractArray, obs_variables::AbstractArray, spinup_forcing::Any)
    output, forcing, observation = unpackYaxOpti(args; forcing_variables)
    forcing = (; Pair.(forcing_variables, forcing)...)
    observation = (; Pair.(obs_variables, observation)...)
    params = optimizeModel(forcing, out, observation,
        tem, optim; spinup_forcing=spinup_forcing)
    output[:] = params.optim
end


function mapOptimizeModel(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, optim::NamedTuple, observations::NamedTuple,
    ; spinup_forcing=nothing, max_cache=1e9)
    incubes = (forcing.data..., observations.data...)
    indims = (forcing.dims..., observations.dims...)
    forcing_variables = forcing.variables |> collect
    outdims = output.paramdims
    out = output.land_init
    obs_variables = observations.variables |> collect


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
        max_cache=max_cache
    )
    return params
end