export optimizeModel, getParameters, updateParameters
export getConstraintNames, getSimulationData, loss, getLoss
export getData
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
function updateParameters(tblParams, approaches)
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
function getConstraintNames(optiInfo, storeVarsList)
    obsVariables = Symbol.(optiInfo.variables2constrain)
    obsVariablesWithSigma = Symbol[]
    for obs in obsVariables
        push!(obsVariablesWithSigma, obs)
        # push!(obsVariablesWithSigma, Symbol(string(obs)*"_σ"))
    end
    modelVariables = String[]
    optimVariables = (;)
    for v in obsVariables
        vinfo = getproperty(optiInfo.constraints.variables, v)
        push!(modelVariables, vinfo.modelFullVar)
        vf = Symbol(split(vinfo.modelFullVar, ".")[1])
        vvar = Symbol(split(vinfo.modelFullVar, ".")[2])
        optimVariables = setTupleField(optimVariables, (v, tuple(vf, vvar)))
    end
    # optimVariables = getVariableGroups(modelVariables)
    storeVariables = getVariableGroups(union(modelVariables, storeVarsList))
    return obsVariablesWithSigma, optimVariables, storeVariables
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getData(outsmodel, observations, obsV, modelVarInfo)
    ŷField = getfield(outsmodel, modelVarInfo[1]) |> columntable
    ŷ = hcat(getfield(ŷField, modelVarInfo[2])...)'
    y = observations |> select(obsV) |> matrix
    yσ = observations |> select(Symbol(string(obsV)*"_σ")) |> matrix
    return (y, yσ, ŷ)
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getSimulationData(outsmodel, observations, optimVars, obsVariables)
    ŷ = [] # Vector{Matrix{Float64}}
    for k in keys(optimVars)
        newkvals = getfield(outsmodel, k) |> columntable
        newkvals = newkvals |> select(keys(getfield(optimVars, k))...)
        # newkvals = newkvals |> select(keys(newkvals)...)
        newkvals = newkvals |> matrix
        newkvals = vcat(newkvals...)
        push!(ŷ, newkvals)
    end
    ŷ = length(ŷ) == 1 ? ŷ[1] : hcat(ŷ...)
    #ŷ = aggregate(ŷ, :monthly)
    y = observations |> select(obsVariables[1:2:end-1]...) |> columntable |> matrix # 2x, no needed, but is here for completeness.
    yσ = observations |> select(obsVariables[2:2:end]...) |> columntable |> matrix # 2x, no needed, but is here for completeness.
    # @show mean(skipmissing(y)), mean(ŷ), modelVariables
    return (y, yσ, ŷ)
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLoss(pVector, forcing, initOut,
    observations, tblParams, obsVariables, optimVars, modelInfo, optiInfo)
    tblParams.optim .= pVector # update the parameters with pVector
    newApproaches = updateParameters(tblParams, modelInfo.models.forward)
    outevolution = runEcosystem(newApproaches, forcing, initOut, modelInfo; nspins=3) # spinup + forward run!
    lossVec=[]
    for obsV in obsVariables
        (y, yσ, ŷ) = getData(outevolution, observations, obsV, getfield(optimVars, obsV))
        push!(lossVec, loss(y, ŷ, Val(:mse)))
    end
    return sum(lossVec)
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModel(forcing, initOut, observations,
    obsVars, optimVars, modelInfo, optiInfo; maxfevals=100, nspins=3)
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);
    
    # get the subset of parameters table that consists of only optimized parameters
    tblParams = getParameters(modelInfo.models.forward, optiInfo.params2opti)
    
    # get the defaults and bounds
    defaults = tblParams.defaults
    lo = tblParams.lower
    hi = tblParams.upper

    # make the cost function handle
    costFunc = x -> getLoss(x, forcing, initOut,
        observations, tblParams, obsVars, optimVars, modelInfo, optiInfo)
    
    # minimize the cost
    results = minimize(costFunc, defaults, 1; lower=lo, upper=hi,
        multi_threading=false, maxfevals=maxfevals)
    
    # get the best results and do a forward run with the optimized parameters
    optim_para = xbest(results)

    # update the parameter table with the optimized values
    tblParams.optim .= optim_para
    newApproaches = updateParameters(tblParams, modelInfo.models.forward)
    outevolution = runEcosystem(newApproaches, forcing, initOut, modelInfo; nspins=nspins) # spinup + forward run!
    return tblParams, outevolution
end