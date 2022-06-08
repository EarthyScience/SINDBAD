export optimizeModel, getParameters, updateParameters
export getConstraintNames, getSimulationData, loss, getLoss

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
        global approachx = approaches[idx] # bad, bad, bad !! #TODO
        if modelName in tblParams.modelsApproach
            vars = propertynames(approachx)
            for var in vars
                inOptim = filtervar(var, modelName, tblParams)
                #TODO
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
    obsVariables = Symbol.(info.opti.variables2constrain)
    modelVariables = String[]
    for v in obsVariables
        vinfo = getproperty(info.opti.constraints.variables, v)
        push!(modelVariables, vinfo.modelFullVar)
    end
    optimizedVariables = getVariableGroups(modelVariables) #["fluxes.gpp", "fluxes.tra", "pools.cVeg"] = (; fluxes=(:gpp, :tra), pools=(:cVeg))
    modelVariables = getVariableGroups(union(modelVariables, info.modelRun.output.variables.store))
    return obsVariables, modelVariables, optimizedVariables
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getSimulationData(outsmodel, observations, optimVars, obsVariables)
    ŷ = [] # Vector{Matrix{Float64}}
    for k in keys(optimVars)
        newkvals = getfield(outsmodel, k) |> columntable
        newkvals = newkvals |> select(keys(newkvals)...)
        newkvals = newkvals |> matrix
        push!(ŷ, newkvals)
    end
    ŷ = length(ŷ) == 1 ? ŷ[1] : hcat(ŷ...)
    #ŷ = aggregate(ŷ, :monthly)
    y = observations |> select(obsVariables...) |> columntable |> matrix # 2x, no needed, but is here for completeness.
    # @show mean(skipmissing(y)), mean(ŷ), modelVariables
    return (y, ŷ)
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLoss(pVector, forcing, initOut,
    observations, tblParams, optimVars, modelInfo, optiInfo, nspins)
    # tblParams.optim .= pVector # update the parameters with pVector
    # @show pVector, typeof(pVector)
    if eltype(pVector) <: ForwardDiff.Dual
        tblParams.optim .= [modelInfo.helpers.numbers.sNT(ForwardDiff.value(v)) for v ∈ pVector] # update the parameters with pVector
    else
        tblParams.optim .= pVector # update the parameters with pVector    
    end

    newApproaches = updateParameters(tblParams, modelInfo.models.forward)
    # outyaks = mapRunEcosystem(forcing, output, info.tem)
    @time outevolution = runEcosystem(newApproaches, forcing, initOut, modelInfo; nspins=nspins) # spinup + forward run!
    lossVec=[]
    cost_options=optiInfo.costOptions;
    for var_row in cost_options
        obsV = var_row.variable
        lossMetric = var_row.costMetric
        (y, yσ, ŷ) = getData(outevolution, observations, obsV, getfield(optimVars, obsV))
        metr = loss(y, ŷ, yσ, Val(lossMetric))
        @show obsV, lossMetric, metr
        push!(lossVec, metr)
    end

    return sum(lossVec)
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModel(forcing, initOut, observations,
    modelInfo, optiInfo; nspins=3)
    optimVars = optiInfo.variables.optim;
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);

    # get the subset of parameters table that consists of only optimized parameters
    tblParams = getParameters(modelInfo.models.forward, optiInfo.optimized_paramaters)

    # get the defaults and bounds
    default_values = tblParams.defaults
    lower_bounds = tblParams.lower
    upper_bounds = tblParams.upper

    # make the cost function handle
    costFunc = x -> getLoss(x, forcing, initOut,
        observations, tblParams, optimVars, modelInfo, optiInfo, nspins)

    # run the optimizer
    optim_para = optimizer(costFunc, default_values, lower_bounds, upper_bounds, optiInfo.algorithm.options, Val(optiInfo.algorithm.method))

    # update the parameter table with the optimized values
    tblParams.optim .= optim_para
    newApproaches = updateParameters(tblParams, selectedModels)
    outevolution = runEcosystem(newApproaches, forcing, initOut, modelVariables, temInfo; nspins=3) # spinup + forward run!
    return tblParams, outevolution
end