export setupExperiment, getInitPools, setNumberType
export getInitStates
export getParameters, updateParameters
using StaticArrays: SVector
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
    modelsObj = [getfield(Models, m) for m in modelsApproach]
    return Table(; names, defaults, optim=defaults, lower, upper, modelsApproach, models, varsModels, modelsObj)
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
updateParameters(tblParams, approaches, pVector)
does not depend on the mutated table of parameters
"""
function updateParameters(tblParams, approaches::Tuple, pVector)
    updatedModels = Models.LandEcosystem[]
    namesApproaches = nameof.(typeof.(approaches)) # a better way to do this?
    for (idx, modelName) in enumerate(namesApproaches)
        approachx = approaches[idx]
        model_obj = approachx
        newapproachx = if modelName in tblParams.modelsApproach
            vars = propertynames(approachx)
            newvals = Pair[]
            for var in vars
                pindex = findall(row -> row.names == var && row.modelsApproach == modelName, tblParams)
                pval = getproperty(approachx, var)
                if !isempty(pindex)
                    model_obj = typeof(approachx)
                    model_obj = tblParams[pindex[1]].modelsObj
                    pval = pVector[pindex[1]]
                else
                    if eltype(pval) <: ForwardDiff.Dual
                        pval = pval
                    else
                        pval = Union{AbstractFloat, ForwardDiff.Dual{AbstractFloat}}(pval)
                        # pval = ForwardDiff.Dual{AbstractFloat}(pval)
                    end

                end
                push!(newvals, var => pval)
            end
            # @show model_obj, newvals
            # @show typeof(approachx), modelName
            # model_obj = getfield(Sindbad.Models, modelName)

            m = model_obj(; newvals...)
            m
            # typeof(approachx)(; newvals...)
            # typeof(approachx)(; newvals...)
        else
            approachx
        end
        push!(updatedModels, newapproachx)
    end
    return (updatedModels...,)
end

"""
    checkSelectedModels(fullModels, selModels)
checks if the list of selected models in modelStructure.json are available in the full list of sindbad_models defined in models.jl.
"""
function checkSelectedModels(fullModels::AbstractArray, selModels::AbstractArray)
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
returns a list of models reordered according to orders provided in modelStructure json.
- default order is taken from sindbad_models
- models cannot be set before getPools or after cCycle
USE WITH EXTREME CAUTION AS CHANGING ORDER MAY RESULT IN MODEL INCONSISTENCY
"""
function changeModelOrder(info::NamedTuple, selModels::AbstractArray)
    fullModels = sindbad_models.model
    checkSelectedModels(fullModels, selModels)
    # get orders of fixed models that cannot be changed
    order_getPools = findfirst(e->e==:getPools, fullModels)
    order_cCycle = findfirst(e->e==:cCycle, fullModels)

    # get the new orders and models from modelStructure.json
    newOrders = Int64[]
    newModels = (;)
    order_changed_warn=true
    for sm in selModels
        modInfo = getfield(info.modelStructure.models, sm)
        if :order in propertynames(modInfo)
            push!(newOrders, modInfo.order)
            newModels = setTupleField(newModels,(sm, modInfo.order))
            if modInfo.order <= order_getPools
                error("The model order for $(sm) is set at $(modInfo.order). Any order earlier than or same as getPools ($order_getPools) is not permitted.")
            end
            if modInfo.order >= order_cCycle
                error("The model order for $(sm) is set at $(modInfo.order). Any order later than or same as cCycle ($order_cCycle) is not permitted.")
            end
            if order_changed_warn
                @info " changeModelOrder:: Model order has been changed through modelStructure.json. Make sure that model structure is consistent by accessing the model list in info.tem.models.selected_models and comparing it with sindbad_models"
                order_changed_warn=false
            end
            @info "     $(sm) order:: old: $(findfirst(e->e==sm, fullModels)), new: $(modInfo.order)"
        end
    end

    #check for duplicates in the order
    if length(newOrders) != length(unique(newOrders))
        nun = nonUnique(newOrders)
        error("There are duplicates in the order [$(nun)] set in modelStructure.json. Cannot set the same order for different models.")
    end

    # sort the orders
    newOrders = sort(newOrders, rev=true)

    # create re-ordered list of full models
    fullModels_reordered = deepcopy(fullModels)
    for new_order in newOrders
        sm=nothing
        for nm in keys(newModels)
            if getproperty(newModels, nm) == new_order
                sm = nm
            end
        end
        old_order = findfirst(e->e==sm, fullModels_reordered)
        # get the models without the model to be re-ordered
        tmp = filter!(e->e≠sm, fullModels_reordered)
        # insert the re-ordered model to the right place
        if old_order >= new_order
            insert!(tmp, new_order, sm)
        else
            insert!(tmp, new_order-1, sm)
        end
        fullModels_reordered = deepcopy(tmp)
    end    
    return fullModels_reordered
    #todo make sure that this function is functioning correctly before deploying it
end

"""
    getOrderedSelectedModels(info::NamedTuple, selModels::AbstractArray)
gets the ordered list of selected models from info.modelStructure.models
- orders them as given in sindbad_models in models.jl. 
- consistency check using checkSelectedModels for the existence of user-provided model.
"""
function getOrderedSelectedModels(info::NamedTuple, selModels::AbstractArray)
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
    setInputParameters(original_table::Table, updated_table::Table)
updates the model parameters based on input from params.json
- new table with the optimised/modified values from params.json.
"""
function setInputParameters(original_table::Table, updated_table::Table)
    upoTable = copy(original_table)
    for i in eachindex(updated_table)
        subtbl = filter(row -> row.names == Symbol(updated_table[i].names) && row.models == Symbol(updated_table[i].models), original_table)
        if isempty(subtbl)
            error("model: $(updated_table[i].names) and model $(updated_table[i].models) not found")
        else
            posmodel = findall(x -> x == Symbol(updated_table[i].models), upoTable.models)
            posvar = findall(x -> x == Symbol(updated_table[i].names), upoTable.names)
            pindx = intersect(posmodel, posvar)
            pindx = length(pindx) == 1 ? pindx[1] : error("Delete duplicates in parameters table.")
            upoTable.optim[pindx] = updated_table.optim[i]
        end
    end
    return upoTable
end

"""
    getTypedModel(model, sNT)
- get Sindbad model, and instatiate them with the datatype set in modelRun
"""
function getTypedModel(model, sNT)
    model_obj = getfield(Sindbad.Models, Symbol(model))
    model_instance = model_obj()
    param_names = fieldnames(model_obj)
    if length(param_names) > 0
        param_vals = []
        for pn=param_names
            param = getfield(model_obj(), pn)
            param_typed = if typeof(param) <: Array
                sNT.(param)
            else
                sNT(param)
            end
            push!(param_vals, param_typed)
        end
        model_instance = model_obj(param_vals...)
    end
    return model_instance
end

"""
    getSpinupAndForwardModels(info::NamedTuple, selModelsOrdered::AbstractArray)
sets the spinup and forward subfields of info.tem.models to select a separated set of model for spinup and forward run. 
- allows for a faster spinup if some models can be turned off
- relies on use4spinup flag in modelStructure
- by design, the spinup models should be subset of forward models
"""
function getSpinupAndForwardModels(info::NamedTuple)
    sel_appr_forward = ()
    sel_appr_spinup = ()
    is_spinup = Int64[]
    selModelsOrdered = info.tem.models.selected_models.model
    defaultModel = getfield(info.modelStructure, :defaultModel)
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.approach
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getTypedModel(Symbol(sel_approach), info.tem.helpers.numbers.sNT)
        # sel_approach_func = getfield(Sindbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if :use4spinup in propertynames(modInfo)
            use4spinup = modInfo.use4spinup
        else
            use4spinup = defaultModel.use4spinup
        end
        if use4spinup == true
            sel_appr_spinup = (sel_appr_spinup..., sel_approach_func)
            push!(is_spinup, 1)
        else
            push!(is_spinup, 0)
        end
    end
    # for t = 1:150-length(sel_appr_forward)
    #     sel_appr_forward = (sel_appr_forward..., getfield(Sindbad.Models, :dummy_sindbad))
    #     push!(is_spinup, 0)
    # end
    # for t = 1:150-length(sel_appr_spinup)
    #     sel_appr_spinup = (sel_appr_spinup..., getfield(Sindbad.Models, :dummy_sindbad))
    # end
    # update the parameters of the approaches if a parameter value has been added from the experiment configuration
    if hasproperty(info, :params) 
        if !isempty(info.params)
            original_params_forward = getParameters(sel_appr_forward);
            input_params = info.params;
            updated_params = setInputParameters(original_params_forward, input_params);
            updated_appr_forward = updateParameters(updated_params, sel_appr_forward);

            original_params_spinup = getParameters(sel_appr_spinup);
            updated_params = setInputParameters(original_params_spinup, input_params);
            updated_appr_spinup = updateParameters(updated_params, sel_appr_spinup);

            info = (; info..., tem=(; info.tem..., models=(; info.tem.models..., forward=updated_appr_forward, is_spinup=is_spinup, spinup=updated_appr_spinup)))
        end
    else
        info = (; info..., tem=(; info.tem..., models=(; info.tem.models..., forward=sel_appr_forward, is_spinup=is_spinup, spinup=sel_appr_spinup)))
    end
    return info
end

"""
    generateDatesInfo(info)
fills info.tem.helpers.dates with date and time related fields needed in the models.
"""
function generateDatesInfo(info::NamedTuple)
    tmpDates = (;)
    timeData = getfield(info.modelRun, :time)
    timeProps = propertynames(timeData)
    for timeProp in timeProps
        tmpDates = setTupleField(tmpDates, (timeProp, getfield(timeData, timeProp)))
    end
    if info.modelRun.time.step == "daily"
        time_range= (Date(info.modelRun.time.sDate):Day(1):Date(info.modelRun.time.eDate))
    elseif info.modelRun.time.step == "hourly"
        time_range= (Date(info.modelRun.time.sDate):Hour(1):Date(info.modelRun.time.eDate))
    else
        error("Sindbad only supports hourly and daily simulation. Change time.step in modelRun.json")
    end
    tmpDates = setTupleField(tmpDates, (:vector, time_range)) #needs to come from the date vector
    tmpDates = setTupleField(tmpDates, (:size, length(time_range))) #needs to come from the date vector
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
                # layerThickNess = repeat([nothing], lenpool)
                layerThickNess = numType.(poolInfo[1])
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
generates the info.tem.helpers.pools and info.pools. The first one is used in the models, while the second one is used in instantiating the pools for initial output tuple.
"""
function generatePoolsInfo(info::NamedTuple)
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
        arrayType = Symbol(getfield(getfield(info.modelStructure.pools, element), :arraytype))
        nlayers = Int64[]
        layerThicknesses = info.tem.helpers.numbers.numType[]
        layer = Int64[]
        inits = info.tem.helpers.numbers.numType[]
        subPoolName = Symbol[]
        mainPoolName = Symbol[]
        mainPools = Symbol.(keys(getfield(getfield(info.modelStructure.pools, element), :components)))
        layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName = getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; numType=info.tem.helpers.numbers.numType)

        # set empty tuple fields
        tpl_fields = (:components, :zix, :initValues, :layerThickness)
        for _tpl in tpl_fields
            tmpElem = setTupleField(tmpElem, (_tpl, (;)))
        end
        hlpElem = setTupleField(hlpElem, (:layerThickness, (;)))
        hlpElem = setTupleField(hlpElem, (:zix, (;)))
        hlpElem = setTupleField(hlpElem, (:zeros, (;)))
        hlpElem = setTupleField(hlpElem, (:ones, (;)))

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
            initValues = createArrayofType(initValues, Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
    
            tmpElem = setTupleSubfield(tmpElem, :components, (mainPool, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (mainPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (mainPool, initValues))
            hlpElem = setTupleSubfield(hlpElem, :zix, (mainPool, zix))
            onetyped = createArrayofType(ones(length(initValues)), Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem, :zeros, (mainPool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (mainPool, onetyped))
            # hlpElem = setTupleSubfield(hlpElem, :zeros, (mainPool, zeros(initValues)))
        end

        # subpools
        uniqueSubPools = Symbol[]
        for _sp in subPoolName
            if _sp ∉ uniqueSubPools
                push!(uniqueSubPools, _sp)
            end
        end
        for subPool in uniqueSubPools
            zix = Int[]
            initValues = info.tem.helpers.numbers.numType[]
            components = Symbol[]
            ltck = info.tem.helpers.numbers.numType[]
            for (ind, par) in enumerate(subPoolName)
                if par == subPool
                    push!(zix, ind)
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(ltck, layerThicknesses[ind])
                end
            end
            initValues = createArrayofType(initValues, Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
            tmpElem = setTupleSubfield(tmpElem, :components, (subPool, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (subPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (subPool, initValues))
            tmpElem = setTupleSubfield(tmpElem, :layerThickness, (subPool, ltck))
            hlpElem = setTupleSubfield(hlpElem, :layerThickness, (subPool, ltck))
            hlpElem = setTupleSubfield(hlpElem, :zix, (subPool, zix))
            onetyped = createArrayofType(ones(length(initValues)), Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem, :zeros, (subPool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (subPool, onetyped))
        end

        ## combined pools
        combinePools = (getfield(getfield(info.modelStructure.pools, element), :combine))
        doCombine = true
        tmpElem = setTupleField(tmpElem, (:combine, (; docombine = true, pool=Symbol(combinePools))))
        if doCombine
            combinedPoolName = Symbol.(combinePools)
            create = Symbol[combinedPoolName]
            components = Symbol[]
            for _sp in subPoolName
                if _sp ∉ components
                    push!(components, _sp)
                end
            end
            # components = Set(Symbol.(subPoolName))
            initValues = inits
            initValues = createArrayofType(initValues, Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
            zix = 1:1:length(mainPoolName) |> collect
            tmpElem = setTupleSubfield(tmpElem, :components, (combinedPoolName, components))
            tmpElem = setTupleSubfield(tmpElem, :zix, (combinedPoolName, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (combinedPoolName, initValues))
            hlpElem = setTupleSubfield(hlpElem, :zix, (combinedPoolName, zix))
            onetyped = createArrayofType(ones(length(initValues)), Nothing[], info.tem.helpers.numbers.numType, nothing, true, Val(arrayType))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem, :zeros, (combinedPoolName, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (combinedPoolName, onetyped))
        else
            create = Symbol.(uniqueSubPools)
        end

        # check if additional variables exist
        if hasproperty(getfield(info.modelStructure.pools, element), :addStateVars)
            addStateVars = getfield(getfield(info.modelStructure.pools, element), :addStateVars)
            tmpElem = setTupleField(tmpElem, (:addStateVars, addStateVars))
        end
        arraytype = :view
        if hasproperty(getfield(info.modelStructure.pools, element), :arraytype)
            arraytype = Symbol(getfield(getfield(info.modelStructure.pools, element), :arraytype))
        end
        tmpElem = setTupleField(tmpElem, (:arraytype, arraytype))
        tmpElem = setTupleField(tmpElem, (:create, create))
        tmpStates = setTupleField(tmpStates, (elSymbol, tmpElem))
        hlpStates = setTupleField(hlpStates, (elSymbol, hlpElem))
    end
    info = (; info..., pools=tmpStates)
    # info = (; info..., tem=(; info.tem..., pools=tmpStates))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlpStates)))
    return info
end

function createArrayofType(inVals, poolArray, numType, indx, ismain, ::Val{:view})
    if ismain
        numType.(inVals)
    else
        @view poolArray[indx]
    end
end

function createArrayofType(inVals, poolArray, numType, indx, ismain, ::Val{:array})
    numType.(inVals)
end


function createArrayofType(inVals, poolArray, numType, indx, ismain, ::Val{:staticarray})
    SVector{length(inVals)}(numType(ix) for ix in inVals)
end


"""
    getInitPools(info)
returns a named tuple with initial pool variables as subfields that is used in out.pools. Uses @view to create components of pools as a view of main pool that just references the original array. 
"""
function getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)
    initPools = (;)
    for element in propertynames(info_pools)
        props = getfield(info_pools, element)
        arrayType = getfield(props, :arraytype)
        toCreate = getfield(props, :create)
        initVals = getfield(props, :initValues)
        for tocr in toCreate
            inVals = deepcopy(getfield(initVals, tocr))
            initPools = setTupleField(initPools, (tocr, createArrayofType(inVals, Nothing[], tem_helpers.numbers.numType, nothing, true, Val(arrayType))))
        end
        tocombine = getfield(getfield(info_pools, element), :combine)
        if tocombine.docombine
            combinedPoolName = tocombine.pool
            zixT = getfield(props, :zix)
            components = keys(zixT)
            poolArray = getfield(initPools, combinedPoolName)
            for component in components
                if component != combinedPoolName
                    indx = getfield(zixT, component)
                    inVals = deepcopy(getfield(initVals, component))
                    compdat = createArrayofType(inVals, poolArray, tem_helpers.numbers.numType, indx, false, Val(arrayType))
                    # compdat::AbstractArray = @view poolArray[indx]
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
function getInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)
    initStates = (;)
    for element in propertynames(info_pools)
        props = getfield(info_pools, element)
        toCreate = getfield(props, :create)
        addVars = getfield(props, :addStateVars)
        initVals = getfield(props, :initValues)
        arrayType = getfield(props, :arraytype)
        for tocr in toCreate
            for avk in keys(addVars)
                avv = getproperty(addVars, avk)
                Δtocr = Symbol(string(avk) * string(tocr))
                vals = ones(tem_helpers.numbers.numType, size(getfield(initVals, tocr))) * tem_helpers.numbers.sNT(avv)
                newvals = createArrayofType(vals, Nothing[], tem_helpers.numbers.numType, nothing, true, Val(arrayType))
                initStates = setTupleField(initStates, (Δtocr, newvals))
            end
        end
        tocombine = getfield(getfield(info_pools, element), :combine)
        if tocombine.docombine
            combinedPoolName = Symbol(tocombine.pool)
            for avk in keys(addVars)
                avv = getproperty(addVars, avk)
                ΔcombinedPoolName = Symbol(string(avk) * string(combinedPoolName))
                zixT = getfield(props, :zix)
                components = keys(zixT)
                ΔpoolArray = getfield(initStates, ΔcombinedPoolName)
                for component in components
                    if component != combinedPoolName
                        Δcomponent = Symbol(string(avk) * string(component))
                        indx = getfield(zixT, component)
                        Δcompdat = createArrayofType(ones(length(indx)) * tem_helpers.numbers.sNT(avv), ΔpoolArray, tem_helpers.numbers.numType, indx, false, Val(arrayType))
                        # Δcompdat::AbstractArray = @view ΔpoolArray[indx]
                        initStates = setTupleField(initStates, (Δcomponent, Δcompdat))
                    end
                end
            end
        end
    end
    return initStates
end


"""
    setNumericHelpers(info, ttype=info.modelRun.rules.data_type)
sets the info.tem.helpers.numbers with the model helpers related to numeric data type. This is essentially a holder of information that is needed to maintain the type of data across models, and has alias for 0 and 1 with the number type selected in info.modelRun.data_type.
"""
function setNumericHelpers(info::NamedTuple, ttype=info.modelRun.rules.data_type)
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
function getVariableGroups(varList::AbstractArray)
    var_dict = Dict()
    for var in varList
        var_l = String(var)
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
function getVariablesToStore(info::NamedTuple)
    writeStoreVars = getVariableGroups(propertynames(info.modelRun.output.variables) |> collect)
    info = (; info..., tem=(; info.tem..., variables=writeStoreVars))
    return info
end


"""
    getLoopingInfo(info)
sets info.tem.variables as the union of variables to write and store from modelrun[.json]. These are the variables for which the time series will be filtered and saved.
"""
function getLoopingInfo(info::NamedTuple)
    run_info = (; info.modelRun.flags..., (output_all=info.modelRun.output.all))
    run_info = setTupleField(run_info, (:loop, (;)))
    run_info = setTupleField(run_info, (:parallelization, Val(Symbol(info.modelRun.mapping.parallelization))))
    for dim in info.modelRun.mapping.runEcosystem
        run_info = setTupleSubfield(run_info, :loop, (Symbol(dim), info.forcing.size[Symbol(dim)]))
        # todo: create the time dimesion using the dates vector
        # if dim == "time"
        #     run_info = setTupleSubfield(run_info, :loop, (Symbol(dim), length(info.tem.helpers.dates.vector)))
        # else
        #     run_info = setTupleSubfield(run_info, :loop, (Symbol(dim), info.forcing.size[Symbol(dim)]))
        # end
    end
    return run_info
end

"""
    getRestartFilePath(info)
Checks if the restartFile in spinup.json is an absolute path. If not, uses experiment_root as the base path to create an absolute path for loadSpinup, and uses output.root as the base for saveSpinup
"""
function getRestartFilePath(info::NamedTuple)
    restartFileIn = info.spinup.paths.restartFileIn
    restartFileOut = info.spinup.paths.restartFileOut
    restart_file = nothing
    if info.spinup.flags.saveSpinup
        if isnothing(restartFileOut)
            error("info.spinup.paths.restartFile is null, but info.spinup.flags.saveSpinup is set to true. Cannot continue. Either give a path for restartFile or set saveSpinup to false")
        else
            # ensure that the output file for spinup is jld2 format
            if restartFileOut[end-4:end] != ".jld2"
                restartFileOut = restartFileOut * ".jld2"
            end
            if isabspath(restartFileOut)
                restart_file = restartFileOut
            else
                restart_file = joinpath(info.output.spinup, restartFileOut)
            end
            info = (; info..., spinup=(; info.spinup..., paths=(; info.spinup.paths..., restartFileOut=restart_file)))
        end
    end

    if info.spinup.flags.loadSpinup
        if isnothing(restartFileIn)
            error("info.spinup.paths.restartFile is null, but info.spinup.flags.loadSpinup is set to true. Cannot continue. Either give a path for restartFile or set loadSpinup to false")
        else
            if restartFileIn[end-4:end] != ".jld2"
                error("info.spinup.paths.restartFile has a file ending other than .jld2. Only jld2 files are supported for loading spinup. Either give a correct file or set info.spinup.flags.loadSpinup to false.")
            end
            if isabspath(restartFileIn)
                restart_file = restartFileIn
            else
                restart_file = joinpath(info.experiment_root, restartFileIn)
            end
        end
        info = (; info..., spinup=(; info.spinup..., paths=(; info.spinup.paths..., restartFileIn=restart_file)))
    end
    return info
end

"""
    setupExperiment(info)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function setupExperiment(info::NamedTuple)
    @info "SetupExperiment: setting Numeric Helpers..."
    info = setNumericHelpers(info)
    @info "SetupExperiment: setting Output Helpers..."
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., output=info.output)))
    @info "SetupExperiment: setting Variable Helpers..."
    info = getVariablesToStore(info)
    @info "SetupExperiment: setting Pools Info..."
    info = generatePoolsInfo(info)
    @info "SetupExperiment: setting Dates Helpers..."
    info = generateDatesInfo(info)
    selModels = propertynames(info.modelStructure.models) |> collect
    # @show sel
    # selModels = (selModels..., :dummy)
    @info "SetupExperiment: setting Models..."
    selected_models = getOrderedSelectedModels(info, selModels)
    info = (; info..., tem=(; info.tem..., models=(; selected_models=Table((; model=[selected_models...])))))
    info = getSpinupAndForwardModels(info)
    # add information related to model run
    @info "SetupExperiment: setting Mapping info..."
    run_info = getLoopingInfo(info);
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., run=run_info)))
    @info "SetupExperiment: setting Spinup Info..."
    info = getRestartFilePath(info)
    infospin=info.spinup
    infospin=setTupleField(infospin, (:sequence, dictToNamedTuple.([infospin.sequence...])))
    info = setTupleSubfield(info, :tem, (:spinup, infospin))
    if info.modelRun.flags.runOpti || info.tem.helpers.run.calcCost
        @info "SetupExperiment: setting Optimization info..."
        info = setupOptimization(info)
    end
    # adjust the model variable list for different model runSpinup
    sel_vars = nothing
    if info.modelRun.flags.runOpti
        sel_vars = info.optim.variables.store
    elseif info.tem.helpers.run.calcCost
        if info.modelRun.flags.runForward
            sel_vars = getVariableGroups(union(String.(keys(info.modelRun.output.variables)), info.optim.variables.model));
        else
            sel_vars = info.optim.variables.store
        end
    else
        sel_vars = info.tem.variables
    end
    info = (; info..., tem=(; info.tem..., variables=sel_vars))
    println("----------------------------------------------")
    return info
end