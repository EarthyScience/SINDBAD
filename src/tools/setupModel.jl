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
    defaultModel = getfield(info.modelStructure, :defaultModel)
    @show defaultModel
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.approach
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getfield(Sinbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if "use4spinup" in propertynames(modInfo)
            use4spinup = modInfo.use4spinup
        else
            use4spinup = defaultModel.use4spinup
        end
        if use4spinup == true
            sel_appr_spinup = (sel_appr_spinup..., sel_approach_func)
        end
    end
    # @set info.tem.models.forward = sel_appr_forward
    # @set info.tem.models.spinup = sel_appr_spinup
    info=(; info..., tem=(; info.tem..., models = (; info.tem.models..., forward = sel_appr_forward, spinup = sel_appr_spinup)));
    return info
end

"""
generateDatesInfo(info)
"""
function generateDatesInfo(info)
    tmpDates = (;)
    timeData=getfield(info.modelRun, :time)
    timeProps = propertynames(timeData)
    @show timeProps
    for timeProp in timeProps
        tmpDates = setTupleField(tmpDates, (timeProp, getfield(timeData, timeProp)))
    end
    # info=(; info..., tem=(; info.tem..., dates = tmpDates));
    info = (; info..., tem=(; helpers=(; info.tem.helpers..., dates = tmpDates))) # aone=aone, azero=azero
    return info
end

"""
generateStatesInfo(info)
"""
function generateStatesInfo(info)
    elements = keys(info.modelStructure.pools)
    tmpStates = (;)
    for element in elements
        elSymbol = Symbol(element)
        tmpElem = (;)
        tmpStates = setTupleField(tmpStates, (elSymbol, (;)))
        poolData = getfield(getfield(info.modelStructure.pools, element), :pools)
        nlayers = []
        layer = []
        inits = []
        subPoolName = []
        mainPoolName = []
        mainPools = Symbol.(getfield(getfield(info.modelStructure.pools, element), :order))
        for mainPool in mainPools
            poolInfo = getproperty(poolData, mainPool)
            if poolInfo isa Array{<:Number,1}
                lenpool = Int64(poolInfo[1])
                append!(nlayers, fill(1, lenpool))
                append!(layer, collect(1:poolInfo[1]))
                append!(inits, fill(poolInfo[2], lenpool))
                append!(subPoolName, fill(mainPool, lenpool))
                append!(mainPoolName, fill(mainPool, lenpool))
            else
                subpools = propertynames(poolInfo)
                for (idx, p) in enumerate(poolInfo)
                    lenpool = Int64(p[1])
                    append!(nlayers, fill(1, lenpool))
                    append!(layer, collect(1:p[1]))
                    append!(inits, fill(p[2], lenpool))
                    append!(subPoolName, fill(Symbol(String(mainPool)*String(subpools[idx])), lenpool))
                    append!(mainPoolName, fill(mainPool, lenpool))
                end
            end
        end
        flags = zeros(length(mainPoolName))
        tmpElem = setTupleField(tmpElem, (:components, (;)))
        tmpElem = setTupleField(tmpElem, (:flags, (;)))
        tmpElem = setTupleField(tmpElem, (:nZix, (;)))
        tmpElem = setTupleField(tmpElem, (:zix, (;)))
        tmpElem = setTupleField(tmpElem, (:initValues, (;)))
        tmpElem = setTupleField(tmpElem, (:layerThickness, (;)))
        for mainPool in mainPools
            # tmpElem = setTupleField(tmpElem, (mainPool, (;)))
            zix=Int[]
            initValues=Float64[]
            components=Symbol[]
            flags = zeros(Int, length(mainPoolName))
            nZix=0
            for (ind, par) in enumerate(mainPoolName)
                if par == mainPool
                    push!(zix, ind)
                    push!(components, subPoolName[ind])
                    push!(initValues, inits[ind])
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            tmpElem = setTupleSubfield(tmpElem, :components, (mainPool, components))
            tmpElem = setTupleSubfield(tmpElem, :flags, (mainPool, flags))
            tmpElem = setTupleSubfield(tmpElem, :nZix, (mainPool, nZix))
            tmpElem = setTupleSubfield(tmpElem, :zix, (mainPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (mainPool, initValues))
        end
        uniqueSubPools = Set(subPoolName)
        for subPool in uniqueSubPools
            zix=Int[]
            initValues=Float64[]
            components=Symbol[]
            nZix=0
            flags = zeros(Int, length(mainPoolName))
            for (ind, par) in enumerate(subPoolName)
                if par == subPool
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(zix, ind)
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            tmpElem = setTupleSubfield(tmpElem, :components, (subPool, components))
            tmpElem = setTupleSubfield(tmpElem, :flags, (subPool, flags))
            tmpElem = setTupleSubfield(tmpElem, :nZix, (subPool, nZix))
            tmpElem = setTupleSubfield(tmpElem, :zix, (subPool, zix))

            if element == :water && subPool == :soilW
                soilLayerDepths = getfield(getfield(info.modelStructure.pools, element), :soilLayerDepths)
                if size(soilLayerDepths, 1) != nZix
                    throw("The number of soil layers in modelStructure[.json] does not match with soil depths specified. Check settings for wSoil and soilLayerDepths.")
                end
                tmpElem = setTupleSubfield(tmpElem, :layerThickness, (subPool, Float64.(soilLayerDepths)))
            end
            tmpElem = setTupleSubfield(tmpElem, :initValues, (subPool, initValues))
        end
        combinePools = (getfield(getfield(info.modelStructure.pools, element), :combine))
        doCombine = combinePools[1]
        if doCombine
            combinedPoolName = Symbol.(combinePools[2])
            create = [combinedPoolName]
            components=Set(Symbol.(subPoolName))
            initValues = Float64.(inits)
            zix = 1:1:length(mainPoolName) |> collect
            flags =ones(Int, length(mainPoolName))
            nZix = length(mainPoolName)
            tmpElem = setTupleSubfield(tmpElem, :components, (combinedPoolName, components))
            tmpElem = setTupleSubfield(tmpElem, :flags, (combinedPoolName, flags))
            tmpElem = setTupleSubfield(tmpElem, :nZix, (combinedPoolName, nZix))
            tmpElem = setTupleSubfield(tmpElem, :zix, (combinedPoolName, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (combinedPoolName, initValues))
        else
            create = Symbol.(uniqueSubPools)
        end
        tmpElem = setTupleField(tmpElem, (:create, create))
        tmpStates = setTupleField(tmpStates, (elSymbol, tmpElem))
        # if element == "water":

    end
    # info=(; info..., tem=(; info.tem..., pools = tmpStates));
    info=(; info..., tem=(; info.tem..., helpers=(;info.tem.helpers..., pools = tmpStates)));
    return info
end

"""
Sets the initial pools pools
"""
function getInitPools(info)
    initPools = (;)
    for element in propertynames(info.tem.helpers.pools)
        props = getfield(info.tem.helpers.pools, element)
        toCreate = getfield(props, :create)
        initVals = getfield(props, :initValues)
        for tocr in toCreate
            inVals = deepcopy(getfield(initVals, tocr))
            initPools = setTupleField(initPools, (tocr, inVals))
        end
    end
    # info = (; info..., tem=(; info.tem..., pools = (; info.tem.pools..., initPools = initPools)));
    return initPools
end

"""
getInitOut(initPools, selected_models)
create the initial out tuple with all models
"""
function getInitOut(info)
    initPools = getInitPools(info)
    out = (;)
    out = (; out..., pools=(;), states=(;), fluxes=(;))
    out = (; out..., pools=(; out.pools..., initPools...))
    # @show selectedModels, string.(selectedModels)
    sortedModels = sort([_sm for _sm in info.tem.models.selected_models])
    for model in sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out

end


"""
Harmonize the information needed to autocompute variables, e.g., sum, water balance, etc.
"""
function setHelpers(info, ttype=info.modelRun.rules.dataType)
    zero = setDataType(ttype)(0)
    one = setDataType(ttype)(1)
    info = (; info..., tem=(;))
    # info = (; info..., tem=(; helpers=(; zero=zero, one=one, numType=setDataType(ttype)))) # aone=aone, azero=azero
    info = (; info..., tem=(; helpers=(; numbers = (; zero=zero, one=one, numType=setDataType(ttype))))) # aone=aone, azero=azero

    return info
end

"""
Harmonize the information needed to autocompute variables, e.g., sum, water balance, etc.
"""
function setDataType(t="Float64")
    ttype = getfield(Main, Symbol(t))
    return ttype
end

# function setHelpers(info)
#     if info.modelRun.rules.dataType == "Float64"
#         zero = 0.0
#         one = 1.0
#         aone = [1.0]
#         azero = [0.0]
#         info=(; info..., tem=(; helpers = (; zero=zero, one=one, aone=aone, azero=azero)));
#     end
# return info
# end

function setupModel!(info)
    info = setHelpers(info)
    info = generateStatesInfo(info)
    info = generateDatesInfo(info)
    selModels = propertynames(info.modelStructure.models)
    fullModels = sindbad_models.model
    info=(; info..., tem=(; info.tem..., models = (; selected_models = selModels)));
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    info = getSelectedApproaches(info, selected_models)
    return info
end

export getInitPools, getInitOut