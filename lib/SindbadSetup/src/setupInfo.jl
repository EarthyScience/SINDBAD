export getInitPools
export getInitStates
export getParameters
export prepNumericHelpers
export replaceCommaSeparatorParams
export setNumberType
export setupInfo

"""
    changeModelOrder(info::NamedTuple, selected_models::AbstractArray)

returns a list of models reordered according to orders provided in model_structure json.

- default order is taken from sindbad_models
- models cannot be set before getPools or after cCycle
- USE WITH EXTREME CAUTION AS CHANGING ORDER MAY RESULT IN MODEL INCONSISTENCY
"""
function changeModelOrder(info::NamedTuple, selected_models::AbstractArray)
    all_sindbad_models = sindbad_models
    checkSelectedModels(all_sindbad_models, selected_models)
    # get orders of fixed models that cannot be changed
    order_getPools = findfirst(e -> e == :getPools, all_sindbad_models)
    order_cCycle = findfirst(e -> e == :cCycle, all_sindbad_models)

    # get the new orders and models from model_structure.json
    newOrders = Int64[]
    newModels = (;)
    order_changed_warn = true
    for sm ∈ selected_models
        modInfo = getfield(info.model_structure.models, sm)
        if :order in propertynames(modInfo)
            push!(newOrders, modInfo.order)
            newModels = setTupleField(newModels, (sm, modInfo.order))
            if modInfo.order <= order_getPools
                error(
                    "The model order for $(sm) is set at $(modInfo.order). Any order earlier than or same as getPools ($order_getPools) is not permitted."
                )
            end
            if modInfo.order >= order_cCycle
                error(
                    "The model order for $(sm) is set at $(modInfo.order). Any order later than or same as cCycle ($order_cCycle) is not permitted."
                )
            end
            if order_changed_warn
                @warn " changeModelOrder:: Model order has been changed through model_structure.json. Make sure that model structure is consistent by accessing the model list in info.tem.models.selected_models and comparing it with sindbad_models"
                order_changed_warn = false
            end
            @warn "     $(sm) order:: old: $(findfirst(e->e==sm, all_sindbad_models)), new: $(modInfo.order)"
        end
    end

    #check for duplicates in the order
    if length(newOrders) != length(unique(newOrders))
        nun = nonUnique(newOrders)
        error(
            "There are duplicates in the order [$(nun)] set in model_structure.json. Cannot set the same order for different models."
        )
    end

    # sort the orders
    newOrders = sort(newOrders; rev=true)

    # create re-ordered list of full models
    fullModels_reordered = deepcopy(all_sindbad_models)
    for new_order ∈ newOrders
        sm = nothing
        for nm ∈ keys(newModels)
            if getproperty(newModels, nm) == new_order
                sm = nm
            end
        end
        old_order = findfirst(e -> e == sm, fullModels_reordered)
        # get the models without the model to be re-ordered
        tmp = filter!(e -> e ≠ sm, fullModels_reordered)
        # insert the re-ordered model to the right place
        if old_order >= new_order
            insert!(tmp, new_order, sm)
        else
            insert!(tmp, new_order - 1, sm)
        end
        fullModels_reordered = deepcopy(tmp)
    end
    return fullModels_reordered
    #todo make sure that this function is functioning correctly before deploying it
end


"""
    checkSelectedModels(all_sindbad_models::AbstractArray, selected_models::AbstractArray)

checks if the list of selected models in model_structure.json are available in the full list of sindbad_models defined in models.jl
"""
function checkSelectedModels(all_sindbad_models, selected_models::AbstractArray)
    for sm ∈ selected_models
        if sm ∉ all_sindbad_models
            @show all_sindbad_models
            error(sm,
                " is not a valid model from all_sindbad_models [Sindbad.sindbad_models]. check model_structure settings in json")
            return false
        end
    end
    return true
end


"""
    convertRunFlagsToTypes(info)

converts the model running related flags to types for dispatch
"""
function convertRunFlagsToTypes(info)
    new_run = (;)
    dr = deepcopy(info.experiment.flags)
    for pr in propertynames(dr)
        prf = getfield(dr, pr)
        prtoset = nothing
        if isa(prf, NamedTuple)
            st = (;)
            for prs in propertynames(prf)
                prsf = getfield(prf, prs)
                st = setTupleField(st, (prs, getTypeInstancesForRunFlags(prs, prsf)))
            end
            prtoset = st
        else
            prtoset = getTypeInstancesForRunFlags(pr, prf)
        end
        new_run = setTupleField(new_run, (pr, prtoset))
    end
    return new_run
end


"""
    createArrayofType(inVals, poolArray, num_type, indx, ismain, Val{:view})

DOCSTRING

# Arguments:
- `inVals`: DESCRIPTION
- `poolArray`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function createArrayofType(inVals, poolArray, num_type, indx, ismain, ::Val{:view})
    if ismain
        num_type.(inVals)
    else
        @view poolArray[[indx...]]
    end
end

"""
    createArrayofType(inVals, poolArray, num_type, indx, ismain, Val{:array})

DOCSTRING

# Arguments:
- `inVals`: DESCRIPTION
- `poolArray`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function createArrayofType(inVals, poolArray, num_type, indx, ismain, ::Val{:array})
    return num_type.(inVals)
end

"""
    createArrayofType(inVals, poolArray, num_type, indx, ismain, Val{:static_array})

DOCSTRING

# Arguments:
- `inVals`: DESCRIPTION
- `poolArray`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function createArrayofType(inVals, poolArray, num_type, indx, ismain, ::Val{:static_array})
    return SVector{length(inVals)}(num_type(ix) for ix ∈ inVals)
    # return SVector{length(inVals)}(num_type(ix) for ix ∈ inVals)
end


"""
    generateDatesInfo(info)

fills info.tem.helpers.dates with date and time related fields needed in the models.
"""

"""
    generateDatesInfo(info::NamedTuple)

DOCSTRING
"""
function generateDatesInfo(info::NamedTuple)
    tmpDates = (;)
    timeData = getfield(info.experiment.basics, :time)
    timeProps = propertynames(timeData)
    for timeProp ∈ timeProps
        propVal = getfield(timeData, timeProp)
        if propVal isa Number
            propVal = info.tem.helpers.numbers.sNT(propVal)
        end
        tmpDates = setTupleField(tmpDates, (timeProp, propVal))
    end
    if info.experiment.basics.time.temporal_resolution == "t_day"
        timestep = Day(1)
        time_range = Date(info.experiment.basics.time.date_begin):Day(1):Date(info.experiment.basics.time.date_end)
    elseif info.experiment.basics.time.temporal_resolution == "hour"
        timestep = Month(1)
        time_range =
            Date(info.experiment.basics.time.date_begin):Hour(1):Date(info.experiment.basics.time.date_end)
    else
        error(
            "Sindbad only supports hourly and daily simulation. Change time.timestep in model_run.json"
        )
    end
    tmpDates = setTupleField(tmpDates, (:temporal_resolution, info.experiment.basics.time.temporal_resolution))
    tmpDates = setTupleField(tmpDates, (:timestep, timestep))
    tmpDates = setTupleField(tmpDates, (:range, time_range))
    tmpDates = setTupleField(tmpDates, (:size, length(time_range)))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., dates=tmpDates)))
    return info
end


"""
    generatePoolsInfo(info)

generates the info.tem.helpers.pools and info.pools. The first one is used in the models, while the second one is used in instantiating the pools for initial output tuple.
"""

"""
    generatePoolsInfo(info::NamedTuple)

DOCSTRING
"""
function generatePoolsInfo(info::NamedTuple)
    elements = keys(info.model_structure.pools)
    tmpStates = (;)
    hlpStates = (;)
    arrayType = Symbol(info.experiment.exe_rules.model_array_type)

    for element ∈ elements
        valsTuple = (;)
        valsTuple = setTupleField(valsTuple, (:zix, (;)))
        valsTuple = setTupleField(valsTuple, (:self, (;)))
        valsTuple = setTupleField(valsTuple, (:all_components, (;)))
        elSymbol = Symbol(element)
        tmpElem = (;)
        hlpElem = (;)
        tmpStates = setTupleField(tmpStates, (elSymbol, (;)))
        hlpStates = setTupleField(hlpStates, (elSymbol, (;)))
        poolData = getfield(getfield(info.model_structure.pools, element), :components)
        # arrayType = Symbol(getfield(getfield(info.model_structure.pools, element), :arraytype))
        nlayers = Int64[]
        layerThicknesses = info.tem.helpers.numbers.num_type[]
        layer = Int64[]
        inits = info.tem.helpers.numbers.num_type[]
        subPoolName = Symbol[]
        mainPoolName = Symbol[]
        mainPools =
            Symbol.(keys(getfield(getfield(info.model_structure.pools, element),
                :components)))
        layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName =
            getPoolInformation(mainPools,
                poolData,
                layerThicknesses,
                nlayers,
                layer,
                inits,
                subPoolName,
                mainPoolName;
                num_type=info.tem.helpers.numbers.sNT)

        # set empty tuple fields
        tpl_fields = (:components, :zix, :initValues, :layerThickness)
        for _tpl ∈ tpl_fields
            tmpElem = setTupleField(tmpElem, (_tpl, (;)))
        end
        hlpElem = setTupleField(hlpElem, (:layerThickness, (;)))
        hlpElem = setTupleField(hlpElem, (:zix, (;)))
        hlpElem = setTupleField(hlpElem, (:components, (;)))
        hlpElem = setTupleField(hlpElem, (:all_components, (;)))
        hlpElem = setTupleField(hlpElem, (:zeros, (;)))
        hlpElem = setTupleField(hlpElem, (:ones, (;)))
        hlpElem = setTupleField(hlpElem, (:vals, (;)))

        # main pools
        for mainPool ∈ mainPoolName
            zix = Int[]
            initValues = info.tem.helpers.numbers.num_type[]
            components = Symbol[]
            for (ind, par) ∈ enumerate(subPoolName)
                if startswith(String(par), String(mainPool))
                    push!(zix, ind)
                    push!(components, subPoolName[ind])
                    push!(initValues, inits[ind])
                end
            end
            initValues = createArrayofType(initValues,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))

            zix = Tuple(zix)

            tmpElem = setTupleSubfield(tmpElem, :components, (mainPool, Tuple(components)))
            tmpElem = setTupleSubfield(tmpElem, :zix, (mainPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (mainPool, initValues))
            hlpElem = setTupleSubfield(hlpElem, :zix, (mainPool, zix))
            hlpElem = setTupleSubfield(hlpElem, :components, (mainPool, Tuple(components)))
            onetyped = createArrayofType(initValues .* info.tem.helpers.numbers.𝟘 .+ info.tem.helpers.numbers.𝟙,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem,
                :zeros,
                (mainPool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (mainPool, onetyped))
            # hlpElem = setTupleSubfield(hlpElem, :zeros, (mainPool, zeros(initValues)))
        end

        # subpools
        uniqueSubPools = Symbol[]
        for _sp ∈ subPoolName
            if _sp ∉ uniqueSubPools
                push!(uniqueSubPools, _sp)
            end
        end
        for subPool ∈ uniqueSubPools
            zix = Int[]
            initValues = info.tem.helpers.numbers.num_type[]
            components = Symbol[]
            ltck = info.tem.helpers.numbers.num_type[]
            for (ind, par) ∈ enumerate(subPoolName)
                if par == subPool
                    push!(zix, ind)
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(ltck, layerThicknesses[ind])
                end
            end
            zix = Tuple(zix)
            initValues = createArrayofType(initValues,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))
            tmpElem = setTupleSubfield(tmpElem, :components, (subPool, Tuple(components)))
            tmpElem = setTupleSubfield(tmpElem, :zix, (subPool, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (subPool, initValues))
            tmpElem = setTupleSubfield(tmpElem, :layerThickness, (subPool, Tuple(ltck)))
            hlpElem = setTupleSubfield(hlpElem, :layerThickness, (subPool, Tuple(ltck)))
            hlpElem = setTupleSubfield(hlpElem, :zix, (subPool, zix))
            hlpElem = setTupleSubfield(hlpElem, :components, (subPool, Tuple(components)))
            onetyped = createArrayofType(initValues .* info.tem.helpers.numbers.𝟘 .+ info.tem.helpers.numbers.𝟙,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem, :zeros,
                (subPool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (subPool, onetyped))
        end

        ## combined pools
        combinePools = (getfield(getfield(info.model_structure.pools, element), :combine))
        doCombine = true
        tmpElem = setTupleField(tmpElem, (:combine, (; docombine=true, pool=Symbol(combinePools))))
        if doCombine
            combinedPoolName = Symbol.(combinePools)
            create = Symbol[combinedPoolName]
            components = Symbol[]
            for _sp ∈ subPoolName
                if _sp ∉ components
                    push!(components, _sp)
                end
            end
            # components = Set(Symbol.(subPoolName))
            initValues = inits
            initValues = createArrayofType(initValues,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))
            zix = collect(1:1:length(mainPoolName))
            zix = Tuple(zix)

            tmpElem = setTupleSubfield(tmpElem, :components, (combinedPoolName, Tuple(components)))
            tmpElem = setTupleSubfield(tmpElem, :zix, (combinedPoolName, zix))
            tmpElem = setTupleSubfield(tmpElem, :initValues, (combinedPoolName, initValues))
            hlpElem = setTupleSubfield(hlpElem, :zix, (combinedPoolName, zix))
            onetyped = createArrayofType(initValues .* info.tem.helpers.numbers.𝟘 .+ info.tem.helpers.numbers.𝟙,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                Val(arrayType))
            all_components = Tuple([_k for _k in keys(tmpElem.zix) if _k !== combinedPoolName])
            hlpElem = setTupleSubfield(hlpElem, :all_components, (combinedPoolName, all_components))
            valsTuple = setTupleSubfield(valsTuple, :zix, (combinedPoolName, Val(hlpElem.zix)))
            valsTuple = setTupleSubfield(valsTuple, :self, (combinedPoolName, Val(combinedPoolName)))
            valsTuple = setTupleSubfield(valsTuple, :all_components, (combinedPoolName, Val(all_components)))
            hlpElem = setTupleField(hlpElem, (:vals, valsTuple))
            hlpElem = setTupleSubfield(hlpElem, :components, (combinedPoolName, Tuple(components)))
            # onetyped = ones(length(initValues))
            hlpElem = setTupleSubfield(hlpElem,
                :zeros,
                (combinedPoolName, onetyped .* info.tem.helpers.numbers.𝟘))
            hlpElem = setTupleSubfield(hlpElem, :ones, (combinedPoolName, onetyped))
        else
            create = Symbol.(uniqueSubPools)
        end

        # check if additional variables exist
        if hasproperty(getfield(info.model_structure.pools, element), :state_variables)
            state_variables = getfield(getfield(info.model_structure.pools, element), :state_variables)
            tmpElem = setTupleField(tmpElem, (:state_variables, state_variables))
        end
        arraytype = :view
        if hasproperty(info.experiment.exe_rules, :model_array_type)
            arraytype = Symbol(info.experiment.exe_rules.model_array_type)
        end
        tmpElem = setTupleField(tmpElem, (:arraytype, arraytype))
        tmpElem = setTupleField(tmpElem, (:create, create))
        tmpStates = setTupleField(tmpStates, (elSymbol, tmpElem))
        hlpStates = setTupleField(hlpStates, (elSymbol, hlpElem))
    end
    hlp_new = (;)
    # tcPrint(hlpStates)
    eleprops = propertynames(hlpStates)
    if :carbon in eleprops && :water in eleprops
        for prop ∈ propertynames(hlpStates.carbon)
            cfield = getproperty(hlpStates.carbon, prop)
            wfield = getproperty(hlpStates.water, prop)
            cwfield = (; cfield..., wfield...)
            if prop == :vals
                cwfield = (;)
                for subprop in propertynames(cfield)
                    csub = getproperty(cfield, subprop)
                    wsub = getproperty(wfield, subprop)
                    cwfield = setTupleField(cwfield, (subprop, (; csub..., wsub...)))
                end
            end
            # @show prop, cfield, wfield
            # tcPrint(cwfield)
            hlp_new = setTupleField(hlp_new, (prop, cwfield))
        end
    elseif :carbon in eleprops && :water ∉ eleprops
        hlp_new = hlpStates.carbon
    elseif :carbon ∉ eleprops && :water in eleprops
        hlp_new = hlpStates.water
    else
        hlp_new = hlpStates
    end
    # hlt_new = setTupleField(hlp_new, (:vals, hlpStates.vals))
    info = (; info..., pools=tmpStates)
    # info = (; info..., tem=(; info.tem..., pools=tmpStates))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlp_new)))
    # info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlpStates)))
    return info
end


"""
    getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)

returns a named tuple with initial pool variables as subfields that is used in out.pools. Uses @view to create components of pools as a view of main pool that just references the original array.
"""

"""
    getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)

DOCSTRING
"""
function getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)
    initPools = (;)
    for element ∈ propertynames(info_pools)
        props = getfield(info_pools, element)
        arrayType = getfield(props, :arraytype)
        toCreate = getfield(props, :create)
        initVals = getfield(props, :initValues)
        for tocr ∈ toCreate
            inVals = deepcopy(getfield(initVals, tocr))
            initPools = setTupleField(initPools,
                (tocr,
                    createArrayofType(inVals,
                        Nothing[],
                        tem_helpers.numbers.sNT,
                        nothing,
                        true,
                        Val(arrayType))))
        end
        tocombine = getfield(getfield(info_pools, element), :combine)
        if tocombine.docombine
            combinedPoolName = tocombine.pool
            zixT = getfield(props, :zix)
            components = keys(zixT)
            poolArray = getfield(initPools, combinedPoolName)
            for component ∈ components
                if component != combinedPoolName
                    indx = getfield(zixT, component)
                    inVals = deepcopy(getfield(initVals, component))
                    compdat = createArrayofType(inVals,
                        poolArray,
                        tem_helpers.numbers.sNT,
                        indx,
                        false,
                        Val(arrayType))
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

returns a named tuple with initial state variables as subfields that is used in out.states. Extended from getInitPools, it uses @view to create components of states as a view of main state that just references the original array. The states to be intantiate are taken from state_variables in model_structure.json. The entries their are prefix to parent pool, when the state variables are created.
"""

"""
    getInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)

DOCSTRING
"""
function getInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)
    initStates = (;)
    for element ∈ propertynames(info_pools)
        props = getfield(info_pools, element)
        toCreate = getfield(props, :create)
        addVars = getfield(props, :state_variables)
        initVals = getfield(props, :initValues)
        arrayType = getfield(props, :arraytype)
        for tocr ∈ toCreate
            for avk ∈ keys(addVars)
                avv = getproperty(addVars, avk)
                Δtocr = Symbol(string(avk) * string(tocr))
                vals =
                    zero(getfield(initVals, tocr)) .+ tem_helpers.numbers.𝟙 *
                                                      tem_helpers.numbers.sNT(avv)
                newvals = createArrayofType(vals,
                    Nothing[],
                    tem_helpers.numbers.sNT,
                    nothing,
                    true,
                    Val(arrayType))
                initStates = setTupleField(initStates, (Δtocr, newvals))
            end
        end
        tocombine = getfield(getfield(info_pools, element), :combine)
        if tocombine.docombine
            combinedPoolName = Symbol(tocombine.pool)
            for avk ∈ keys(addVars)
                avv = getproperty(addVars, avk)
                ΔcombinedPoolName = Symbol(string(avk) * string(combinedPoolName))
                zixT = getfield(props, :zix)
                components = keys(zixT)
                ΔpoolArray = getfield(initStates, ΔcombinedPoolName)
                for component ∈ components
                    if component != combinedPoolName
                        Δcomponent = Symbol(string(avk) * string(component))
                        indx = getfield(zixT, component)
                        Δcompdat = createArrayofType((zero(getfield(initVals, component)) .+ tem_helpers.numbers.𝟙) .*
                                                     tem_helpers.numbers.sNT(avv),
                            ΔpoolArray,
                            tem_helpers.numbers.sNT,
                            indx,
                            false,
                            Val(arrayType))
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
    getLoopingInfo(info)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved.
"""

"""
    getLoopingInfo(info::NamedTuple)

DOCSTRING
"""
function getLoopingInfo(info::NamedTuple)
    run_vals = convertRunFlagsToTypes(info)
    run_info = (; run_vals..., (output_all = Val(info.experiment.model_output.all)))
    run_info = setTupleField(run_info, (:use_forward_diff, run_vals.use_forward_diff))
    parallelization = titlecase(info.experiment.exe_rules.parallelization)
    run_info = setTupleField(run_info, (:parallelization, getfield(SindbadSetup, Symbol("Use"*parallelization*"Parallelization"))()))
    return run_info
end


"""
    getNumberType(t::String)
A helper function to get the number type from the specified string
"""

"""
    getNumberType(t::String)

DOCSTRING
"""
function getNumberType(t::String)
    ttype = eval(Meta.parse(t))
    return ttype
end

"""
    getNumberType(t::DataType)
A helper function to get the number type from the specified string
"""

"""
    getNumberType(t::DataType)

DOCSTRING
"""
function getNumberType(t::DataType)
    return t
end


"""
    getOrderedSelectedModels(info::NamedTuple, selected_models::AbstractArray)

gets the ordered list of selected models from info.model_structure.models
- orders them as given in sindbad_models in models.jl.
- consistency check using checkSelectedModels for the existence of user-provided model.
"""
function getOrderedSelectedModels(info::NamedTuple, selected_models::AbstractArray)
    all_sindbad_models_reordered = changeModelOrder(info, selected_models)
    checkSelectedModels(all_sindbad_models_reordered, selected_models)
    selModelsOrdered = []
    for msm ∈ all_sindbad_models_reordered
        if msm in selected_models
            push!(selModelsOrdered, msm)
        end
    end

    return selModelsOrdered
end

"""
    getParameters(selectedModels)

DOCSTRING
"""
function getParameters(selectedModels)
    default = [flatten(selectedModels)...]
    constrains = metaflatten(selectedModels, Models.bounds)
    nbounds = length(constrains)
    lower = [constrains[i][1] for i ∈ 1:nbounds]
    upper = [constrains[i][2] for i ∈ 1:nbounds]
    name = [fieldnameflatten(selectedModels)...] # SVector(flatten(x))
    model_approach = [parentnameflatten(selectedModels)...]
    model = [Symbol(supertype(getproperty(Models, m))) for m ∈ model_approach]
    name_full = [join((model[i], name[i]), ".") for i ∈ 1:nbounds]
    approach_func = [getfield(Models, m) for m ∈ model_approach]
    return Table(;
        name,
        default,
        optim=default,
        lower,
        upper,
        model,
        model_approach,
        approach_func,
        name_full)
end


"""
    getParameters(selectedModels, model_parameter_default)

retrieve all model parameters
"""
function getParameters(selectedModels, model_parameter_default)
    default = [flatten(selectedModels)...]
    constrains = metaflatten(selectedModels, Models.bounds)
    nbounds = length(constrains)
    lower = [constrains[i][1] for i ∈ 1:nbounds]
    upper = [constrains[i][2] for i ∈ 1:nbounds]
    name = [fieldnameflatten(selectedModels)...] # SVector(flatten(x))
    model_approach = [parentnameflatten(selectedModels)...]
    model = [Symbol(supertype(getproperty(Models, m))) for m ∈ model_approach]
    name_full = [join((model[i], name[i]), ".") for i ∈ 1:nbounds]
    approach_func = [getfield(Models, m) for m ∈ model_approach]
    dp_dist = typeof(default[1]).(model_parameter_default[:distribution][2])
    # dp_dist = Tuple(dp_dist)
    dist = [model_parameter_default[:distribution][1] for m ∈ model_approach]
    p_dist = [dp_dist for m ∈ model_approach]
    is_ml = [model_parameter_default.is_ml for m ∈ model_approach]
    return Table(;
        name,
        default,
        optim=default,
        lower,
        upper,
        model,
        model_approach,
        approach_func,
        name_full,
        dist,
        p_dist,
        is_ml)
end

"""
    getParameters(selectedModels, model_parameter_default, opt_parameter::Vector)

DOCSTRING

# Arguments:
- `selectedModels`: DESCRIPTION
- `model_parameter_default`: DESCRIPTION
- `opt_parameter`: DESCRIPTION
"""
function getParameters(selectedModels, model_parameter_default, opt_parameter::Vector)
    opt_parameter = replaceCommaSeparatorParams(opt_parameter)
    paramstbl = getParameters(selectedModels, model_parameter_default)
    return filter(row -> row.name_full in opt_parameter, paramstbl)
end

"""
    getParameters(selectedModels, model_parameter_default, opt_parameter::NamedTuple)

DOCSTRING

# Arguments:
- `selectedModels`: DESCRIPTION
- `model_parameter_default`: DESCRIPTION
- `opt_parameter`: DESCRIPTION
"""
function getParameters(selectedModels, model_parameter_default, opt_parameter::NamedTuple)
    param_list = replaceCommaSeparatorParams(keys(opt_parameter))
    paramstbl = getParameters(selectedModels, model_parameter_default, param_list)
    pTable = filter(row -> row.name_full in param_list, paramstbl)
    new_dist = pTable.dist
    new_p_dist = pTable.p_dist
    new_is_ml = pTable.is_ml
    pInd = 1
    for pp ∈ param_list
        p_ = opt_parameter[pInd]
        if !isnothing(p_)
            if hasproperty(p_, :is_ml)
                new_is_ml[pInd] = getfield(p_, :is_ml)
            end
            if hasproperty(p_, :distribution)
                nd = getproperty(p_, :distribution)
                new_dist[pInd] = nd[1]
                new_p_dist[pInd] = nd[2]
            end
        end
        pInd = pInd + 1
    end
    pTable.is_ml .= new_is_ml
    pTable.dist .= new_dist
    pTable.p_dist .= new_p_dist
    return pTable
end


"""
    getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; prename="", num_type=Float64)

A helper function to get the information of each pools from info.model_structure.pools and puts them into arrays of information needed to instantiate pool variables.
"""

"""
    getPoolInformation(mainPools, poolData, layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName; prename = , num_type = Float64)

DOCSTRING

# Arguments:
- `mainPools`: DESCRIPTION
- `poolData`: DESCRIPTION
- `layerThicknesses`: DESCRIPTION
- `nlayers`: DESCRIPTION
- `layer`: DESCRIPTION
- `inits`: DESCRIPTION
- `subPoolName`: DESCRIPTION
- `mainPoolName`: DESCRIPTION
- `prename`: DESCRIPTION
- `num_type`: DESCRIPTION
"""
function getPoolInformation(mainPools,
    poolData,
    layerThicknesses,
    nlayers,
    layer,
    inits,
    subPoolName,
    mainPoolName;
    prename="",
    num_type=Float64)
    for mainPool ∈ mainPools
        prefix = prename
        poolInfo = getproperty(poolData, mainPool)
        if !isa(poolInfo, NamedTuple)
            if isa(poolInfo[1], Number)
                lenpool = poolInfo[1]
                # layerThickNess = repeat([nothing], lenpool)
                layerThickNess = num_type.(poolInfo[1])
            else
                lenpool = length(poolInfo[1])
                layerThickNess = num_type.(poolInfo[1])
            end

            append!(layerThicknesses, layerThickNess)
            append!(nlayers, fill(1, lenpool))
            append!(layer, collect(1:lenpool))
            append!(inits, fill(num_type(poolInfo[2]), lenpool))

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
            layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName =
                getPoolInformation(subPools,
                    poolInfo,
                    layerThicknesses,
                    nlayers,
                    layer,
                    inits,
                    subPoolName,
                    mainPoolName;
                    prename=prefix,
                    num_type=num_type)
        end
    end
    return layerThicknesses, nlayers, layer, inits, subPoolName, mainPoolName
end

"""
    getRestartFilePath(info::NamedTuple)

Checks if the restartFile in experiment.model_spinup is an absolute path. If not, uses experiment_root as the base path to create an absolute path for loadSpinup, and uses output.root as the base for saveSpinup
"""
function getRestartFilePath(info::NamedTuple)
    restart_file_in = info.experiment.model_spinup.paths.restart_file_in
    restart_file_out = info.experiment.model_spinup.paths.restart_file_out
    restart_file = nothing
    if info.experiment.flags.spinup.save_spinup
        if isnothing(restart_file_out)
            error(
                "info.experiment.model_spinup.paths.restartFile is null, but info.experiment.flags.spinup.save_spinup is set to true. Cannot continue. Either give a path for restartFile or set saveSpinup to false"
            )
        else
            # ensure that the output file for spinup is jld2 format
            if restart_file_out[(end-4):end] != ".jld2"
                restart_file_out = restart_file_out * ".jld2"
            end
            if isabspath(restart_file_out)
                restart_file = restart_file_out
            else
                restart_file = joinpath(info.output.spinup, restart_file_out)
            end
            info = (;
                info...,
                spinup=(;
                    info.experiment.model_spinup...,
                    paths=(; info.experiment.model_spinup.paths..., restart_file_out=restart_file)))
        end
    end

    if info.experiment.flags.spinup.load_spinup
        if isnothing(restart_file_in)
            error(
                "info.experiment.model_spinup.paths.restartFile is null, but info.experiment.flags.spinup.load_spinup is set to true. Cannot continue. Either give a path for restartFile or set loadSpinup to false"
            )
        else
            if restart_file_in[(end-4):end] != ".jld2"
                error(
                    "info.experiment.model_spinup.paths.restartFile has a file ending other than .jld2. Only jld2 files are supported for loading spinup. Either give a correct file or set info.experiment.flags.spinup.load_spinup to false."
                )
            end
            if isabspath(restart_file_in)
                restart_file = restart_file_in
            else
                restart_file = joinpath(info.experiment_root, restart_file_in)
            end
        end
        info = (;
            info...,
            spinup=(;
                info.experiment.model_spinup...,
                paths=(; info.experiment.model_spinup.paths..., restart_file_in=restart_file)))
    end
    return info
end


"""
    getSpinupAndForwardModels(info::NamedTuple)

sets the spinup and forward subfields of info.tem.models to select a separated set of model for spinup and forward run.

  - allows for a faster spinup if some models can be turned off
  - relies on use_in_spinup flag in model_structure
  - by design, the spinup models should be subset of forward models
"""
function getSpinupAndForwardModels(info::NamedTuple)
    sel_appr_forward = ()
    sel_appr_spinup = ()
    is_spinup = Int64[]
    selModelsOrdered = info.tem.models.selected_models.model
    default_model = getfield(info.model_structure, :default_model)
    for sm ∈ selModelsOrdered
        modInfo = getfield(info.model_structure.models, sm)
        modAppr = modInfo.approach
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getTypedModel(Symbol(sel_approach), info.tem.helpers.numbers.sNT)
        # sel_approach_func = getfield(Sindbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if :use_in_spinup in propertynames(modInfo)
            use_in_spinup = modInfo.use_in_spinup
        else
            use_in_spinup = default_model.use_in_spinup
        end
        if use_in_spinup == true
            push!(is_spinup, 1)
        else
            push!(is_spinup, 0)
        end
    end
    # change is_spinup to a vector of indices
    is_spinup = findall(is_spinup .== 1)

    # update the parameters of the approaches if a parameter value has been added from the experiment configuration
    if hasproperty(info, :parameters)
        if !isempty(info.parameters)
            original_params_forward = getParameters(sel_appr_forward)
            input_params = info.parameters
            updated_params = setInputParameters(original_params_forward, input_params)
            updated_appr_forward = updateModelParameters(updated_params, sel_appr_forward)

            info = (;
                info...,
                tem=(;
                    info.tem...,
                    models=(;
                        info.tem.models...,
                        forward=updated_appr_forward,
                        is_spinup=is_spinup)))
        end
    else
        info = (;
            info...,
            tem=(;
                info.tem...,
                models=(;
                    info.tem.models...,
                    forward=sel_appr_forward,
                    is_spinup=is_spinup)))
    end
    return info
end


"""
    getTypedModel(model, sNT)

get Sindbad model, and instatiate them with the datatype set in model_run
"""
function getTypedModel(model, sNT)
    model_obj = getfield(Sindbad.Models, Symbol(model))
    model_instance = model_obj()
    param_names = fieldnames(model_obj)
    if length(param_names) > 0
        param_vals = []
        for pn ∈ param_names
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
    getTypeInstanceForSpinupMode(mode_name)

a helper function to get the type for spinup mode
"""
function getTypeInstanceForSpinupMode(option_name::String)
    opt_ss = join(titlecase.(split(option_name,"_")))
    struct_instance = getfield(SindbadSetup, Symbol(opt_ss))()
    return struct_instance
end


"""
    getTypeInstancesForRunFlags(option_name, option_value)

a helper function to get the type for run related flags
"""
function getTypeInstancesForRunFlags(option_name::Symbol, option_value)
    opt_s = string(option_name)
    opt_ss = join(uppercasefirst.(split(opt_s,"_")))
    if option_value
        structname = "Do"*opt_ss
    else
        structname = "Dont"*opt_ss
    end
    struct_instance = getfield(SindbadSetup, Symbol(structname))()
    return struct_instance
end

"""
    getVariableGroups(varList::AbstractArray)

get named tuple for variables groups from list of variables. Assumes that the entries in the list follow subfield.variablename of model output (land
"""
function getVariableGroups(varList::AbstractArray)
    var_dict = Dict()
    for var ∈ varList
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
    for (k, v) ∈ var_dict
        varNT = setTupleField(varNT, (Symbol(k), tuple(Symbol.(v)...)))
    end
    return varNT
end

"""
    getVariablesToStore(info::NamedTuple)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved
"""
function getVariablesToStore(info::NamedTuple)
    writeStoreVars = getVariableGroups(collect(propertynames(info.experiment.model_output.variables)))
    info = (; info..., tem=(; info.tem..., variables=writeStoreVars))
    return info
end



"""
    parseSaveCode(info)

parse and save the code and structs of selected model structure for the given experiment
"""
function parseSaveCode(info)
    models = info.tem.models.forward
    outfile_define = joinpath(info.output.code, info.experiment.basics.name * "_" * info.experiment.basics.domain * "_model_definitions.jl")
    outfile_code = joinpath(info.output.code, info.experiment.basics.name * "_" * info.experiment.basics.domain * "_model_functions.jl")
    outfile_struct = joinpath(info.output.code, info.experiment.basics.name * "_" * info.experiment.basics.domain * "_model_structs.jl")
    fallback_code_define = nothing
    fallback_code_precompute = nothing
    fallback_code_compute = nothing

    # write define
    open(outfile_define, "w") do o_file
        mod_string = "# code for define functions (variable definition) in models of SINDBAD for $(info.experiment.basics.name) experiment applied to $(info.experiment.basics.domain) domain. These functions are called just ONCE for variable/array definitions\n"
        write(o_file, mod_string)
        mod_string = "# based on @code_string from CodeTracking.jl. In case of conflicts, follow the original code in define functions of model approaches in src/Models/[model]/[approach].jl\n"
        write(o_file, mod_string)
        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            mod_file = joinpath(info.sindbad_root, "src/Models", mod_name, appr_name * ".jl")
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# call order: $mi\n\n"
            write(o_file, mod_string)

            mod_ending = "\n\n"
            if mi == lastindex(models)
                mod_ending = "\n"
            end
            mod_code = @code_string Models.define(_mod, nothing, nothing, nothing)
            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_define)
                    fallback_code_define = mod_code
                end
            else
                write(o_file, mod_code * mod_ending)
            end
            mod_string = "# --------------------------------------\n"
            write(o_file, mod_string)

        end
        mod_string = "\n# fallback define function for LandEcosystem\n"
        write(o_file, mod_string)
        write(o_file, fallback_code_define)
    end

    #write precompute and compute
    open(outfile_code, "w") do o_file
        mod_string = "# code for precompute and compute functions in models of SINDBAD for $(info.experiment.basics.name) experiment applied to $(info.experiment.basics.domain) domain. The precompute functions are called once outside the time loop per iteration in optimization, while compute functions are called every time step. So, derived parameters that depend on model parameters that are optimized should be placed in precompute functions\n"
        mod_string = "# code for models of SINDBAD for $(info.experiment.basics.name) experiment applied to $(info.experiment.basics.domain) domain\n"
        write(o_file, mod_string)
        mod_string = "# based on @code_string from CodeTracking.jl. In case of conflicts, follow the original code in model approaches in src/Models/[model]/[approach].jl\n"
        write(o_file, mod_string)
        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            mod_file = joinpath(info.sindbad_root, "src/Models", mod_name, appr_name * ".jl")
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# call order: $mi\n\n"
            write(o_file, mod_string)

            mod_ending = "\n\n"

            mod_code = @code_string Models.precompute(_mod, nothing, nothing, nothing)

            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_precompute)
                    fallback_code_precompute = mod_code * "\n\n"
                end
            else
                write(o_file, mod_code * mod_ending)
            end


            mod_code = @code_string Models.compute(_mod, nothing, nothing, nothing)
            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_compute)
                    fallback_code_compute = mod_code
                end
            else
                write(o_file, mod_code * mod_ending)
            end
            mod_string = "# --------------------------------------\n"
            write(o_file, mod_string)

        end
        mod_string = "\n# fallback precompute and compute functions for LandEcosystem\n"
        write(o_file, mod_string)
        write(o_file, fallback_code_precompute)
        write(o_file, fallback_code_compute)
    end

    # write structs
    open(outfile_struct, "w") do o_file
        mod_string = "# code for parameter structs of SINDBAD for $(info.experiment.basics.name) experiment applied to $(info.experiment.basics.domain) domain\n"
        write(o_file, mod_string)
        mod_string = "# based on @code_expr from CodeTracking.jl. In case of conflicts, follow the original code in model approaches in src/Models/[model]/[approach].jl\n\n"
        write(o_file, mod_string)
        write(o_file, "abstract type LandEcosystem end\n")

        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_file = joinpath(info.sindbad_root, "src/Models", mod_name, appr_name * ".jl")
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# call order: $mi\n\n"
            write(o_file, mod_string)

            write(o_file, "abstract type $mod_name <: LandEcosystem end\n")

            mod_string = string(@code_expr typeof(_mod)())
            for xx = 1:100 # maximum line number with parameter definition. Chanage here if with crazy model with large number of parameters still show file path in generated struct.
                if occursin(mod_file, mod_string)
                    mod_string = replace(mod_string, "#= $(mod_file):$(xx) =#\n" => "")
                    mod_string = replace(mod_string, "#= $(mod_file):$(xx) =#" => "")
                end
            end
            mod_string = replace(mod_string, " @bounds " => "@bounds")
            mod_string = replace(mod_string, "@describe(" => "@describe")
            mod_string = replace(mod_string, "@units(" => "@units")
            mod_string = replace(mod_string, "@with_kw(" => "@with_kw ")
            mod_string = replace(mod_string, "                    end)))" => "end")
            mod_string = replace(mod_string, "                end)))" => "end")
            mod_string = replace(mod_string, "    end" => "end")
            mod_string = replace(mod_string, "                                        " => "    ")
            mod_string = replace(mod_string, " = ((" => " = ")
            mod_string = replace(mod_string, ") |" => " |")
            # mod_string = "\n # todo get model structs here \n"
            write(o_file, mod_string * "\n\n")
            # mod_code = @code_string Models.compute(_mod, nothing, nothing, nothing)
            # write(o_file, mod_code * "\n")
            mod_string = "# --------------------------------------\n"
            if mi == lastindex(models)
                mod_string = "# --------------------------------------"
            end

            write(o_file, mod_string)
        end
    end

    return nothing
end

"""
    prepNumericHelpers(info::NamedTuple, ttype)

prepare helpers related to numeric data type. This is essentially a holder of information that is needed to maintain the type of data across models, and has alias for 0 and 1 with the number type selected in info.model_run
"""
function prepNumericHelpers(info::NamedTuple, ttype)
    num_type = getNumberType(ttype)
    𝟘 = num_type(0.0)
    𝟙 = num_type(1.0)

    tolerance = num_type(info.experiment.exe_rules.tolerance)
    info = (; info..., tem=(;))
    sNT = (a) -> num_type(a)
    if occursin("ForwardDiff.Dual", info.experiment.exe_rules.data_type)
        tag_type = ForwardDiff.tagtype(𝟘)
        @show tag_type, num_type
        try
            sNT = (a) -> num_type(tag_type(a))
            𝟘 = sNT(0.0)
            𝟙 = sNT(1.0)
            tolerance = sNT(info.experiment.exe_rules.tolerance)
        catch
            sNT = (a) -> num_type(a)
            𝟘 = sNT(0.0)
            𝟙 = sNT(1.0)
            tolerance = sNT(info.experiment.exe_rules.tolerance)
        end
    end
    num_helpers = (;
        𝟘=𝟘,
        𝟙=𝟙,
        tolerance=tolerance,
        num_type=num_type,
        sNT=sNT
    )
    return num_helpers
end

"""
    replaceCommaSeparatorParams(p_names_list)

DOCSTRING
"""
function replaceCommaSeparatorParams(p_names_list)
    o_p_names_list = []
    foreach(p_names_list) do p
        p_name = splitRenameParam(p, ",")
        push!(o_p_names_list, p_name)
    end
    return o_p_names_list
end

"""
    splitRenameParam(_p::Symbol, _splitter)

DOCSTRING
"""
function splitRenameParam(_p::Symbol, _splitter)
    p_string = String(_p)
    return splitRenameParam(p_string, _splitter)
end

"""
    splitRenameParam(p_string::String, _splitter)

DOCSTRING
"""
function splitRenameParam(p_string::String, _splitter)
    p_name = strip(p_string)
    if occursin(_splitter, p_string)
        p_split = split(p_string, _splitter)
        p_model = strip(first(p_split))
        p_param = strip(last(p_split))
        p_name = "$(p_model).$(p_param)"
    end
    return p_name
end



"""
    setInputParameters(original_table::Table, updated_table::Table)

updates the model parameters based on input from params.json

  - new table with the optimised/modified values from params.json.
"""

"""
    setInputParameters(original_table::Table, updated_table::Table)

DOCSTRING
"""
function setInputParameters(original_table::Table, updated_table::Table)
    upoTable = copy(original_table)
    for i ∈ eachindex(updated_table)
        subtbl = filter(
            row ->
                row.name == Symbol(updated_table[i].name) &&
                    row.model == Symbol(updated_table[i].model),
            original_table)
        if isempty(subtbl)
            error("model: parameter $(updated_table[i].name) not found in model $(updated_table[i].models). Make sure that the parameter exists in the selected approach for $(updated_table[i].models) or correct the parameter name in params input.")
        else
            posmodel = findall(x -> x == Symbol(updated_table[i].model), upoTable.model)
            posvar = findall(x -> x == Symbol(updated_table[i].name), upoTable.name)
            pindx = intersect(posmodel, posvar)
            pindx = length(pindx) == 1 ? pindx[1] : error("Delete duplicates in parameters table.")
            upoTable.optim[pindx] = updated_table.optim[i]
        end
    end
    return upoTable
end


"""
    setNumericHelpers(info::NamedTuple, ttype)

prepare helpers related to numeric data type. This is essentially a holder of information that is needed to maintain the type of data across models, and has alias for 0 and 1 with the number type selected in info.model_run
"""
function setNumericHelpers(info::NamedTuple, ttype=info.experiment.exe_rules.data_type)
    num_helpers = prepNumericHelpers(info, ttype)
    info = (;
        info...,
        tem=(; helpers=(; numbers=num_helpers)))
    return info
end


"""
    setupInfo(info::NamedTuple)

uses the configuration info and processes information for spinup
"""
function setSpinupInfo(info)
    info = getRestartFilePath(info)
    infospin = info.experiment.model_spinup
    # change spinup sequence dispatch variables to Val, get the temporal aggregators
    seqq = infospin.sequence
    for seq in seqq
        for kk in keys(seq)
            if kk == "forcing"
                skip_aggregation = false
                if startswith(kk, info.tem.helpers.dates.temporal_resolution)
                    skip_aggregation = true
                end
                aggregator = createTimeAggregator(info.tem.helpers.dates.range, seq[kk], mean, skip_aggregation)
                seq["aggregator"] = aggregator
                seq["aggregator_type"] = TimeNoDiff()
                if occursin("_year", seq[kk])
                    seq["aggregator"] = vcat(aggregator[1].indices...)
                    seq["aggregator_type"] = TimeIndexed()
                end
            end
            if kk == "spinup_mode"
                seq[kk] = getTypeInstanceForSpinupMode(seq[kk])
            end
            if seq[kk] isa String
                seq[kk] = Symbol(seq[kk])
            end
        end
    end

    infospin = setTupleField(infospin, (:sequence, dictToNamedTuple.([seqq...])))
    info = setTupleSubfield(info, :tem, (:spinup, infospin))
    return info
end

"""
    setupInfo(info::NamedTuple)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function setupInfo(info::NamedTuple)
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
    selected_models = collect(propertynames(info.model_structure.models))
    # @show sel
    # selected_models = (selected_models..., :dummy)
    @info "SetupExperiment: setting Models..."
    selected_models = getOrderedSelectedModels(info, selected_models)
    info = (;
        info...,
        tem=(;
            info.tem...,
            models=(; selected_models=Table((; model=[selected_models...])))))
    info = getSpinupAndForwardModels(info)
    @info "SetupExperiment:         ....saving selected models code..."
    _ = parseSaveCode(info)

    # add information related to model run
    @info "SetupExperiment: setting Mapping info..."
    run_info = getLoopingInfo(info)
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., run=run_info)))
    @info "SetupExperiment: setting Spinup Info..."
    info = setSpinupInfo(info)
    if info.experiment.flags.run_optimization || info.experiment.flags.calc_cost
        @info "SetupExperiment: setting Optimization and Observation info..."
        info = setupOptimization(info)
    end
    # adjust the model variable list for different model spinupTEM
    sel_vars = nothing
    if info.experiment.flags.run_optimization
        sel_vars = info.optim.variables.store
    elseif info.experiment.flags.calc_cost
        if info.experiment.flags.run_forward
            sel_vars = getVariableGroups(
                union(String.(keys(info.experiment.model_output.variables)),
                    info.optim.variables.model)
            )
        else
            sel_vars = info.optim.variables.store
        end
    else
        sel_vars = info.tem.variables
    end
    info = (; info..., tem=(; info.tem..., variables=sel_vars))
    @info "\n----------------------------------------------\n"
    return info
end

