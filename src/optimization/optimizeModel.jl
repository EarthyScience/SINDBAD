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
    models = [Symbol(supertypes(@eval $m)[2]) for m in modelsApproach]
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
function updateParameters(tblParams, approaches)
    function filtervar(var, modelName, tblParams)
        filter(row -> row.names == var && row.modelsApproach == modelName, tblParams).optim[1]
    end
    updatedModels = []
    namesApproaches = nameof.(typeof.(approaches)) # a better way to do this?
    for (idx, modelName) in enumerate(namesApproaches)
        global approachx = approaches[idx] # bad, bad, bad !!
        if modelName in tblParams.modelsApproach
            vars = propertynames(approachx)
            for var in vars
                inOptim = filtervar(var, modelName, tblParams)
                @eval (@set! approachx.$var = $inOptim)
            end
        end
        push!(updatedModels, approachx)
    end
    return (updatedModels...,)
end

"""
getConstraintNames(info)
"""
function getConstraintNames(info)
    obsnames = Symbol.(info.opti.variables2constrain)
    modelnames = Symbol[]
    for v in obsnames
        vinfo = getproperty(info.opti.constraints.variables, v)
        push!(modelnames, Symbol(vinfo.modelFullVar))
    end
    return obsnames, modelnames
end

"""
getSimulationData(outsmodel, observations, modelnames, obsnames)
"""
function getSimulationData(outsmodel, observations, modelnames, obsnames)
    # ŷ = outsmodel.fluxes |> columntable |> select(modelnames...) |> matrix
    # y = observations |> select(obsnames...) |> columntable |> matrix # 2x, no needed, but is here for completeness.
    ŷ = outsmodel.fluxes |> select(modelnames...) |> columntable |> matrix
    y = observations |> select(obsnames...) |> columntable |> matrix # 2x, no needed, but is here for completeness.
    # @show mean(skipmissing(y)), mean(ŷ), modelnames
    return (y, ŷ)
end

"""
loss(y::Matrix, ŷ::Matrix)
"""
function loss(y::Matrix, ŷ::Matrix)
    return mean(skipmissing(abs2.(y .- ŷ)))
end

"""
getLoss(pVector, approaches, initStates, forcing, observations, tblParams, obsnames, modelnames)
"""
function getLoss(pVector, approaches, initStates, forcing, info,
    observations, tblParams, obsnames, modelnames)
    tblParams.optim .= pVector # update the parameters with pVector
    newApproaches = updateParameters(tblParams, approaches)
    outevolution = runEcosystem(newApproaches, initStates, forcing, info; nspins=3) # spinup + forward run!
    # @show propertynames(outevolution)
    (y, ŷ) = getSimulationData(outevolution, observations, modelnames, obsnames)
    return loss(y, ŷ)
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initStates, obsnames, modelnames)
"""
function optimizeModel(forcing, info, observations, selectedModels, optimParams, initStates, obsnames, modelnames; maxfevals=100)
    tblParams = getParameters(selectedModels, optimParams)
    lo = tblParams.lower
    hi = tblParams.upper
    defaults = tblParams.defaults
    costFunc = x -> getLoss(x, selectedModels, initStates, forcing, info,
        observations, tblParams, obsnames, modelnames)
    results = minimize(costFunc, defaults, 1; lower=lo, upper=hi,
        multi_threading=false, maxfevals=maxfevals)
    optim_para = xbest(results)
    tblParams.optim .= optim_para
    newApproaches = updateParameters(tblParams, selectedModels)
    outevolution = runEcosystem(newApproaches, initStates, forcing, info; nspins=3) # spinup + forward run!
    return tblParams, outevolution
end