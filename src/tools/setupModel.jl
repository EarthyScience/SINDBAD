function checkModelForcingExists(info, forcingVariables)
    println("Not done")
end

function checkSelectedModels(fullModels, selModels)
    # consistency check for selected model structure
    for sm in selModels
        if sm ∉ fullModels
            println(sm, "is not a valid model from fullModels check model structure") # should throw error
            return false
        end
    end
    return true
end

function getSelectedOrderedModels(fullModels, selModels)
    if checkSelectedModels(fullModels, selModels)
        selModelsOrdered = []
        for msm in fullModels
            if msm in selModels
                push!(selModelsOrdered, msm)
            end
        end
        return selModelsOrdered
    end
end

function getSelectedApproaches(info, selModelsOrdered)
    sel_appr_forward = ()
    sel_appr_spinup = ()
    println(selModelsOrdered)
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.apprName
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getfield(Sinbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if modInfo.use4spinup == true
            sel_appr_spinup = (sel_appr_spinup..., sel_approach_func)
        end
    end
    # @set info.tem.models.forward = sel_appr_forward
    # @set info.tem.models.spinup = sel_appr_spinup
    info=(; info..., tem=(; info.tem..., models = (; forward = sel_appr_forward, spinup = sel_appr_spinup)));
    return info
end

"""
generateStatesInfoTable(pools)

pools = info.modelStructure.states.c
"""
function generateStatesInfoTable(info)
    elements = keys(info.modelStructure.states)
    tmpStates = (;)
    for element in elements
        elSymbol = Symbol(element)
        tmpElem = (;)
        tmpStates = setTupleField(tmpStates, (elSymbol, (;)))
        poolData = getfield(getfield(info.modelStructure.states, element), :pools)
        nlayers = []
        layer = []
        ntypes = []
        inits = []
        subPoolName = []
        mainPoolName = []
        mainPools = Symbol.(getfield(getfield(info.modelStructure.states, element), :order))
        for mainPool in mainPools
            poolInfo = getproperty(poolData, mainPool)
            if poolInfo isa Array{<:Number,1}
                lenpool = Int64(poolInfo[1])
                append!(nlayers, fill(1, lenpool))
                append!(layer, collect(1:poolInfo[1]))
                append!(ntypes, fill(poolInfo[2], lenpool))
                append!(inits, fill(poolInfo[3], lenpool))
                append!(subPoolName, fill(mainPool, lenpool))
                append!(mainPoolName, fill(mainPool, lenpool))
            else
                subpools = propertynames(poolInfo)
                for (idx, p) in enumerate(poolInfo)
                    lenpool = Int64(p[1])
                    append!(nlayers, fill(1, lenpool))
                    append!(layer, collect(1:p[1]))
                    append!(ntypes, fill(p[2], lenpool))
                    append!(inits, fill(p[3], lenpool))
                    append!(subPoolName, fill(Symbol(String(mainPool)*String(subpools[idx])), lenpool))
                    append!(mainPoolName, fill(mainPool, lenpool))
                end
            end
        end
        flags = zeros(length(mainPoolName))
        for mainPool in mainPools
            tmpElem = setTupleField(tmpElem, (mainPool, (;)))
            zix=Int[]
            typeDim=Int[]
            initValues=Float64[]
            components=Symbol[]
            flags = zeros(Int, length(mainPoolName))
            nZix=0
            for (ind, par) in enumerate(mainPoolName)
                if par == mainPool
                    push!(zix, ind)
                    push!(components, subPoolName[ind])
                    push!(initValues, inits[ind])
                    push!(typeDim, ntypes[ind])
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            tmpElem = setTupleSubfield(tmpElem, mainPool, (:components, components))
            tmpElem = setTupleSubfield(tmpElem, mainPool, (:flags, flags))
            tmpElem = setTupleSubfield(tmpElem, mainPool, (:nZix, nZix))
            tmpElem = setTupleSubfield(tmpElem, mainPool, (:zix, zix))
            if maximum(typeDim) > 1
                initValues = repeat(initValues, inner=[1, maximum(typeDim)])
            end
            tmpElem = setTupleSubfield(tmpElem, mainPool, (:initValues, initValues))
        end
        uniqueSubPools = Set(subPoolName)
        for subPool in uniqueSubPools
            tmpElem = setTupleField(tmpElem, (subPool, (;)))
            zix=Int[]
            initValues=Float64[]
            components=Symbol[]
            nZix=0
            typeDim=Int[]
            flags = zeros(Int, length(mainPoolName))
            for (ind, par) in enumerate(subPoolName)
                if par == subPool
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(zix, ind)
                    push!(typeDim, ntypes[ind])
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            tmpElem = setTupleSubfield(tmpElem, subPool, (:components, components))
            tmpElem = setTupleSubfield(tmpElem, subPool, (:flags, flags))
            tmpElem = setTupleSubfield(tmpElem, subPool, (:nZix, nZix))
            tmpElem = setTupleSubfield(tmpElem, subPool, (:zix, zix))
            if maximum(typeDim) > 1
                initValues = repeat(initValues, inner=[1, maximum(typeDim)])
            end
            tmpElem = setTupleSubfield(tmpElem, subPool, (:initValues, initValues))
        end
        combinePools = (getfield(getfield(info.modelStructure.states, element), :combine))
        doCombine = combinePools[1]
        if doCombine
            combinedPoolName = Symbol.(combinePools[2])
            tmpElem = setTupleField(tmpElem, (combinedPoolName, (;)))
            create = [combinedPoolName]
            components=Set(Symbol.(subPoolName))
            initValues = Float64.(inits)
            zix = 1:1:length(mainPoolName) |> collect
            flags =ones(Int, length(mainPoolName))
            nZix = length(mainPoolName)
            tmpElem = setTupleSubfield(tmpElem, combinedPoolName, (:components, components))
            tmpElem = setTupleSubfield(tmpElem, combinedPoolName, (:flags, flags))
            tmpElem = setTupleSubfield(tmpElem, combinedPoolName, (:nZix, nZix))
            tmpElem = setTupleSubfield(tmpElem, combinedPoolName, (:zix, zix))
            if maximum(ntypes) > 1
                initValues = repeat(initValues, inner=[1, maximum(ntypes)])
            end
            tmpElem = setTupleSubfield(tmpElem, combinedPoolName, (:initValues, initValues))
        else
            create = Symbol.(uniqueSubPools)
        end
        tmpElem = setTupleField(tmpElem, (:create, create))
        tmpStates = setTupleField(tmpStates, (elSymbol, tmpElem))
    end
    info=(; info..., tem=(; info.tem..., states = tmpStates));
    return info
end

"""
Sets the initial states pools
"""
function getInitStates(info)
    initStates = (;)
    for element in propertynames(info.tem.states)
        props = getfield(info.tem.states, element)
        toCreate = getfield(props, :create)
        for tocr in toCreate
            inVals = getfield(getfield(props, tocr), :initValues)
            initStates = setTupleField(initStates, (tocr, inVals))
        end
    end
    # info = (; info..., tem=(; info.tem..., states = (; info.tem.states..., initStates = initStates)));
    return initStates

return info
end
"""
Harmonize the information needed to autocompute variables, e.g., sum, water balance, etc.
"""
function setAutoCompute(info)
    vars2sum = info.modelRun.varsToSum
    tarr=propertynames(vars2sum)
    tmp = (;sum=(;))
    for tarname in tarr
        tmpTarr = (;)
        tmpTarr = setTupleField(tmpTarr, (tarname, (;)))
        comps = Symbol.(getfield(vars2sum, tarname).components)
        tmpTarr = setTupleSubfield(tmpTarr, tarname, (:components, comps))
        outfield = Symbol.(getfield(vars2sum, tarname).outfield)
        tmpTarr = setTupleSubfield(tmpTarr, tarname, (:fieldname, outfield))
        tmp = (; tmp..., sum = (; tmp.sum..., tmpTarr...))
    end
    info=(; info..., tem=(; compute = (; tmp...)));
return info
end

function setupModel!(info)
    info = setAutoCompute(info)
    info = generateStatesInfoTable(info)
    selModels = propertynames(info.modelStructure.models)
    # corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
    # info=(; info..., paths=(coreTEM = corePath));
    # include(corePath)
    fullModels = propertynames(getEcosystem())
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    info = getSelectedApproaches(info, selected_models)
    return info
end

export getInitStates