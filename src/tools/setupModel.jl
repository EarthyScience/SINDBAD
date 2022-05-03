export setupModel!, getInitPools, createInitOut, setNumberType

"""
    checkSelectedModels(fullModels, selModels)
checks if the list of selected models in modelStructure.json are available in the full list of sindbad_models defined in models.jl.
"""
function checkSelectedModels(fullModels, selModels)
    for sm in selModels
        if sm ∉ fullModels
            @show fullModels
            error(sm, " is not a valid model from fullModels. check modelStructure settings in json")
            return false
        end
    end
    return true
end

"""
    changeModelOrder(info, selModels)
returns a list of models reordered according to orders provided in modelStructure json. Needs further check before full implementation. Therefore, just returns the fullModels from sindbad_models for now.
"""
function changeModelOrder(info, selModels)
    fullModels = sindbad_models.model
    fullModels_reordered=Vector{Symbol}(undef, length(fullModels))
    checkSelectedModels(fullModels, selModels)
    newOrders = []
    for sm in selModels
        modInfo = getfield(info.modelStructure.models, sm)
        if :order in propertynames(modInfo)
            push!(newOrders, modInfo.order)
            fullModels_reordered[modInfo.order]=sm
        end
    end
    fmInd = 1
    for (ind, fm) in enumerate(fullModels)
        if ind ∉ newOrders
            fullModels_reordered[fmInd] = fm
            fmInd = fmInd + 1
        else
            fmInd = fmInd + 1
            fullModels_reordered[fmInd] = fm
        end

    end
    println("changeModelOrder is not fully functional yet. So, returns sindbad_models as is as full models")
    # @show fullModels_reordered, length(fullModels_reordered)
    return fullModels
end

"""
    getOrderedSelectedModels(info, selModels)
gets the list of selected models from info.modelStructure.models, and orders them as given in sindbad_models in models.jl. A consistency check is carried out using checkSelectedModels for the existence of the model.
"""
function getOrderedSelectedModels(info, selModels)
    fullModels = changeModelOrder(info, selModels)
    checkSelectedModels(fullModels, selModels)
    selModelsOrdered = []
    for msm in fullModels
        if msm in selModels
            push!(selModelsOrdered, msm)
        end
    end
    return selModelsOrdered
end

"""
    getSpinupAndForwardModels(info, selModelsOrdered)
sets the spinup and forward subfields of info.tem.models to select a separated set of model for spinup and forward run. This allows for a faster spinup if some models can be turned off. Relies on use4spinup flag in modelStructure. By design, the spinup models should be subset of forward models.
"""
function getSpinupAndForwardModels(info, selModelsOrdered)
    sel_appr_forward = ()
    sel_appr_spinup = ()
    defaultModel = getfield(info.modelStructure, :defaultModel)
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.approach
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getfield(Sinbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if :use4spinup in propertynames(modInfo)
            use4spinup = modInfo.use4spinup
        else
            use4spinup = defaultModel.use4spinup
        end
        if use4spinup == true
            sel_appr_spinup = (sel_appr_spinup..., sel_approach_func)
        end
    end
    info = (; info..., tem=(; info.tem..., models=(; info.tem.models..., forward=sel_appr_forward, spinup=sel_appr_spinup)))
    return info
end

"""
    generateDatesInfo(info)
fills info.tem.helpers.dates with date and time related fields needed in the models.
"""
function generateDatesInfo(info)
    tmpDates = (;)
    timeData = getfield(info.modelRun, :time)
    timeProps = propertynames(timeData)
    for timeProp in timeProps
        tmpDates = setTupleField(tmpDates, (timeProp, getfield(timeData, timeProp)))
    end
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., dates=tmpDates)))
    return info
end

"""
    getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; prename="", numType=Float64)
A helper function to get the information of each pools from info.modelStructure.pools and puts them into arrays of information needed to instantiate pool variables.
"""
function getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; prename="", numType=Float64)
    for mainPool in mainPools
        prefix = prename
        poolInfo = getproperty(poolData, mainPool)
        if !isa(poolInfo, NamedTuple)
            if isa(poolInfo[1], Number)
                lenpool = poolInfo[1]
                layerThickNess = repeat([nothing], lenpool)
            else
                lenpool = length(poolInfo[1])
                layerThickNess = numType.(poolInfo[1])
            end

            append!(layerThicknesses, layerThickNess)
            append!(nlayers, fill(1, lenpool))
            append!(layer, collect(1:lenpool))
            append!(inits, fill(numType(poolInfo[2]), lenpool))

            if prename == ""
                append!(subPoolName, fill(mainPool, lenpool))
                append!(mainPoolName, fill(mainPool, lenpool))
            else
                append!(subPoolName, fill(Symbol(String(prename) * string(mainPool)), lenpool))
                append!(mainPoolName, fill(Symbol(String(prename)), lenpool))
            end
        else
            prefix = prename * String(mainPool)
            subPools = propertynames(poolInfo)
            layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName = getPoolInformation(subPools, poolInfo, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; prename=prefix, numType=numType)
        end
    end
    return layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName
end

"""
    generatePoolsInfo(info)
generates the info.tem.helpers.pools and info.tem.pools. The first one is used in the models, while the second one is used in instantiating the pools for initial output tuple.
"""
function generatePoolsInfo(info)
    elements = keys(info.modelStructure.pools)
    tmpStates = (;)
    hlpStates = (;)
    for element in elements
        elSymbol = Symbol(element)
        tmpElem = (;)
        hlpElem = (;)
        tmpStates = setTupleField(tmpStates, (elSymbol, (;)))
        hlpStates = setTupleField(hlpStates, (elSymbol, (;)))
        poolData = getfield(getfield(info.modelStructure.pools, element), :components)
        nlayers = []
        layerThicknesses = []
        layer = []
        inits = []
        subPoolName = []
        mainPoolName = []
        mainPools = Symbol.(keys(getfield(getfield(info.modelStructure.pools, element), :components)))
        layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName = getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; numType=info.tem.helpers.numbers.numType)

        # set empty tuple fields
        tpl_fields = (:components, :zix, :initValues, :layerThickness)
        for _tpl in tpl_fields
            tmpElem = setTupleField(tmpElem, (_tpl, (;)))
        end
        hlpElem = setTupleField(hlpElem, (:layerThickness, (;)))

        # main pools
        for mainPool in mainPoolName
            zix = Int[]
            initValues = info.tem.helpers.numbers.numType[]
            components = Symbol[]
            for (ind, par) in enumerate(subPoolName)
                if startswith(String(par), String(mainPool))
                    push!(zix, ind)
                    push!(components, subPoolName[ind])
                    push!(initValues, inits[ind])
                end
            end
            tmpElem = setTupleSubfield(tmpElem, :components, (mainPool, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (mainPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (mainPool, initValues))
        end

        # subpools
        uniqueSubPools = []
        for _sp in subPoolName
            if _sp ∉ uniqueSubPools
                push!(uniqueSubPools, _sp)
            end
        end
        for subPool in uniqueSubPools
            zix = Int[]
            initValues = Float64[]
            components = Symbol[]
            ltck = []
            for (ind, par) in enumerate(subPoolName)
                if par == subPool
                    push!(zix, ind)
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(ltck, layerThicknesses[ind])
                end
            end
            tmpElem = setTupleSubfield(tmpElem, :components, (subPool, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (subPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (subPool, initValues))
            tmpElem = setTupleSubfield(tmpElem, :layerThickness, (subPool, ltck))
            hlpElem = setTupleSubfield(hlpElem, :layerThickness, (subPool, ltck))
        end

        ## combined pools
        combinePools = (getfield(getfield(info.modelStructure.pools, element), :combine))
        doCombine = combinePools[1]
        if doCombine
            combinedPoolName = Symbol.(combinePools[2])
            create = [combinedPoolName]
            components = []
            for _sp in subPoolName
                if _sp ∉ components
                    push!(components, _sp)
                end
            end
            # components = Set(Symbol.(subPoolName))
            initValues = Float64.(inits)
            zix = 1:1:length(mainPoolName) |> collect
            tmpElem = setTupleSubfield(tmpElem, :components, (combinedPoolName, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (combinedPoolName, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (combinedPoolName, initValues))
        else
            create = Symbol.(uniqueSubPools)
        end

        # check if additional variables exist
        if hasproperty(getfield(info.modelStructure.pools, element), :addStateVars)
            addStateVars = getfield(getfield(info.modelStructure.pools, element), :addStateVars)
            tmpElem = setTupleField(tmpElem, (:addStateVars, addStateVars))
        end
        tmpElem = setTupleField(tmpElem, (:create, create))
        tmpStates = setTupleField(tmpStates, (elSymbol, tmpElem))
        hlpStates = setTupleField(hlpStates, (elSymbol, hlpElem))
    end
    info = (; info..., tem=(; info.tem..., pools=tmpStates))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlpStates)))
    return info
end

"""
    getInitPools(info)
returns a named tuple with initial pool variables as subfields that is used in out.pools. Uses @view to create components of pools as a view of main pool that just references the original array. 
"""
function getInitPools(info)
    initPools = (;)
    for element in propertynames(info.tem.pools)
        props = getfield(info.tem.pools, element)
        toCreate = getfield(props, :create)
        initVals = getfield(props, :initValues)
        for tocr in toCreate
            inVals = deepcopy(getfield(initVals, tocr))
            initPools = setTupleField(initPools, (tocr, info.tem.helpers.numbers.numType.(inVals)))
        end
        tocombine = getfield(getfield(info.modelStructure.pools, element), :combine)
        if tocombine[1]
            combinedPoolName = Symbol(tocombine[2])
            zixT = getfield(props, :zix)
            components = keys(zixT)
            poolArray = getfield(initPools, combinedPoolName)
            for component in components
                if component != combinedPoolName
                    indx = getfield(zixT, component)
                    compdat = @view poolArray[indx]
                    initPools = setTupleField(initPools, (component, compdat))
                end
            end
        end
    end
    return initPools
end

"""
    getInitStates(info)
returns a named tuple with initial state variables as subfields that is used in out.states. Extended from getInitPools, it uses @view to create components of states as a view of main state that just references the original array. The states to be intantiate are taken from addStateVars in modelStructure.json. The entries their are prefix to parent pool, when the state variables are created.
"""
function getInitStates(info)
    initStates = (;)
    for element in propertynames(info.tem.pools)
        props = getfield(info.tem.pools, element)
        toCreate = getfield(props, :create)
        addVars = getfield(props, :addStateVars)
        initVals = getfield(props, :initValues)
        for tocr in toCreate
            for avk in keys(addVars)
                avv = getproperty(addVars, avk)
                Δtocr = Symbol(string(avk) * string(tocr))
                vals = ones(info.tem.helpers.numbers.numType, size(getfield(initVals, tocr))) * info.tem.helpers.numbers.sNT(avv)
                initStates = setTupleField(initStates, (Δtocr, vals))
            end
        end
        tocombine = getfield(getfield(info.modelStructure.pools, element), :combine)
        if tocombine[1]
            combinedPoolName = Symbol(tocombine[2])
            for avk in keys(addVars)
                ΔcombinedPoolName = Symbol(string(avk) * string(combinedPoolName))
                zixT = getfield(props, :zix)
                components = keys(zixT)
                ΔpoolArray = getfield(initStates, ΔcombinedPoolName)
                for component in components
                    if component != combinedPoolName
                        Δcomponent = Symbol(string(avk) * string(component))
                        indx = getfield(zixT, component)
                        Δcompdat = @view ΔpoolArray[indx]
                        initStates = setTupleField(initStates, (Δcomponent, Δcompdat))
                    end
                end
            end
        end
    end
    return initStates
end

"""
    createInitOut(info)
create the initial out named tuple with subfields for pools, states, and all selected models.
"""
function createInitOut(info)
    initPools = getInitPools(info)
    initStates = getInitStates(info)
    out = (; fluxes=(;), pools=initPools, states=initStates)
    sortedModels = sort([_sm for _sm in info.tem.models.selected_models])
    for model in sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end


"""
    setNumericHelpers(info, ttype=info.modelRun.rules.dataType)
sets the info.tem.helpers.numbers with the model helpers related to numeric data type. This is essentially a holder of information that is needed to maintain the type of data across models, and has alias for 0 and 1 with the number type selected in info.modelRun.dataType.
"""
function setNumericHelpers(info, ttype=info.modelRun.rules.dataType)
    𝟘 = setNumberType(ttype)(0)
    𝟙 = setNumberType(ttype)(1)
    tolerance = setNumberType(ttype)(info.modelRun.rules.tolerance)
    info = (; info..., tem=(;))
    sNT = (a) -> setNumberType(ttype)(a)
    squarer = (n) -> n .* n
    cuber = (n) -> n .* n .* n
    info = (; info..., tem=(; helpers=(; numbers=(; 𝟘=𝟘, 𝟙=𝟙, tolerance=tolerance, numType=setNumberType(ttype), sNT=sNT, squarer=squarer, cuber=cuber))))
    return info
end

"""
    setNumberType(t="Float64")
A helper function to set the number type to the specified data type
"""
function setNumberType(t="Float64")
    ttype = getfield(Main, Symbol(t))
    return ttype
end


"""
    getVariableGroups(varList)
get named tuple for variables groups from list of variables. Assumes that the entries in the list follow subfield.variablename of model output (land).
"""
function getVariableGroups(varList)
    var_dict = Dict()
    for var_l in varList
        vf = split(var_l, ".")[1]
        vvar = split(var_l, ".")[2]
        if vf ∉ keys(var_dict)
            var_dict[vf] = []
            push!(var_dict[vf], vvar)
        else
            push!(var_dict[vf], vvar)
        end
    end
    varNT = (;)
    for (k, v) in var_dict
        varNT = setTupleField(varNT, (Symbol(k), tuple(Symbol.(v)...)))
    end
    return varNT
end

"""
    getVariablesToStore(info)
sets info.tem.variables as the union of variables to write and store from modelrun[.json]. These are the variables for which the time series will be filtered and saved.
"""
function getVariablesToStore(info)
    writeStoreVars = getVariableGroups(union(info.modelRun.output.variables.write, info.modelRun.output.variables.store))
    info = (; info..., tem=(; info.tem..., variables=writeStoreVars))
    return info
end

"""
    setupModel!(info)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function setupModel!(info)
    info = setNumericHelpers(info)
    info = getVariablesToStore(info)
    info = generatePoolsInfo(info)
    info = generateDatesInfo(info)
    selModels = propertynames(info.modelStructure.models)
    info = (; info..., tem=(; info.tem..., models=(; selected_models=selModels)))
    selected_models = getOrderedSelectedModels(info, selModels)
    info = getSpinupAndForwardModels(info, selected_models)
    return info
end