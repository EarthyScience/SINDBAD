export getInitPools
export getInitStates
export getParameters
export getTypeInstanceForFlags
export getTypeInstanceForNamedOptions
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
    all_sindbad_models = [sindbad_models...]
    checkSelectedModels(all_sindbad_models, selected_models)
    # get orders of fixed models that cannot be changed
    order_getPools = findfirst(e -> e == :getPools, all_sindbad_models)
    order_cCycle = findfirst(e -> e == :cCycle, all_sindbad_models)

    # get the new orders and models from model_structure.json
    new_orders = Int64[]
    new_models = (;)
    order_changed_warn = true
    for sm ∈ selected_models
        model_info = getfield(info.model_structure.models, sm)
        if :order in propertynames(model_info)
            push!(new_orders, model_info.order)
            new_models = setTupleField(new_models, (sm, model_info.order))
            if model_info.order <= order_getPools
                error(
                    "The model order for $(sm) is set at $(model_info.order). Any order earlier than or same as getPools ($order_getPools) is not permitted."
                )
            end
            if model_info.order >= order_cCycle
                error(
                    "The model order for $(sm) is set at $(model_info.order). Any order later than or same as cCycle ($order_cCycle) is not permitted."
                )
            end
            if order_changed_warn
                @warn "changeModelOrder:: Model order has been changed through model_structure.json. Make sure that model structure is consistent by accessing the model list in info.tem.models.selected_models and comparing it with sindbad_models"
                order_changed_warn = false
            end
            @warn "$(sm) [$(Pair(findfirst(e->e==sm, all_sindbad_models), model_info.order))]"
        end
    end

    #check for duplicates in the order
    if length(new_orders) != length(unique(new_orders))
        nun = nonUnique(new_orders)
        error(
            "There are duplicates in the order [$(nun)] set in model_structure.json. Cannot set the same order for different models."
        )
    end

    # sort the orders
    new_orders = sort(new_orders; rev=true)

    # create re-ordered list of full models
    full_models_reordered = deepcopy(all_sindbad_models)
    for new_order ∈ new_orders
        sm = nothing
        for nm ∈ keys(new_models)
            if getproperty(new_models, nm) == new_order
                sm = nm
            end
        end
        old_order = findfirst(e -> e == sm, full_models_reordered)
        # get the models without the model to be re-ordered
        tmp = filter!(e -> e ≠ sm, full_models_reordered)
        # insert the re-ordered model to the right place
        if old_order >= new_order
            insert!(tmp, new_order, sm)
        else
            insert!(tmp, new_order - 1, sm)
        end
        full_models_reordered = deepcopy(tmp)
    end
    return full_models_reordered
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
                st = setTupleField(st, (prs, getTypeInstanceForFlags(prs, prsf)))
            end
            prtoset = st
        else
            prtoset = getTypeInstanceForFlags(pr, prf)
        end
        new_run = setTupleField(new_run, (pr, prtoset))
    end
    return new_run
end


"""
    createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayView)



# Arguments:
- `input_values`: DESCRIPTION
- `pool_array`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `::ModelArrayView`: DESCRIPTION
"""
function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayView)
    if ismain
        num_type.(input_values)
    else
        @view pool_array[[indx...]]
    end
end

"""
    createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayArray)



# Arguments:
- `input_values`: DESCRIPTION
- `pool_array`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `::ModelArrayArray`: DESCRIPTION
"""
function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayArray)
    return num_type.(input_values)
end

"""
    createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayStaticArray)



# Arguments:
- `input_values`: DESCRIPTION
- `pool_array`: DESCRIPTION
- `num_type`: DESCRIPTION
- `indx`: DESCRIPTION
- `ismain`: DESCRIPTION
- `::ModelArrayStaticArray`: DESCRIPTION
"""
function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayStaticArray)
    input_typed = typeof(num_type(1.0)) === eltype(input_values) ? input_values : num_type.(input_values) 
    return SVector{length(input_values)}(input_typed)
    # return SVector{length(input_values)}(num_type(ix) for ix ∈ input_values)
end


"""
    generateDatesInfo(info::NamedTuple)

fills info.tem.helpers.dates with date and time related fields needed in the models.

"""
function generateDatesInfo(info::NamedTuple)
    tmp_dates = (;)
    time_info = getfield(info.experiment.basics, :time)
    time_props = propertynames(time_info)
    for time_prop ∈ time_props
        prop_val = getfield(time_info, time_prop)
        if prop_val isa Number
            prop_val = info.tem.helpers.numbers.sNT(prop_val)
        end
        tmp_dates = setTupleField(tmp_dates, (time_prop, prop_val))
    end
    timestep = getfield(Dates, Symbol(titlecase(info.experiment.basics.time.temporal_resolution)))(1)
    time_range = Date(info.experiment.basics.time.date_begin):timestep:Date(info.experiment.basics.time.date_end)
    tmp_dates = setTupleField(tmp_dates, (:temporal_resolution, info.experiment.basics.time.temporal_resolution))
    tmp_dates = setTupleField(tmp_dates, (:timestep, timestep))
    tmp_dates = setTupleField(tmp_dates, (:range, time_range))
    tmp_dates = setTupleField(tmp_dates, (:size, length(time_range)))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., dates=tmp_dates)))
    return info
end


"""
    generatePoolsInfo(info::NamedTuple)

generates the info.tem.helpers.pools and info.pools. The first one is used in the models, while the second one is used in instantiating the pools for initial output tuple.

"""
function generatePoolsInfo(info::NamedTuple)
    elements = keys(info.model_structure.pools)
    tmp_states = (;)
    hlp_states = (;)
    model_array_type = getfield(SindbadSetup, toUpperCaseFirst(info.experiment.exe_rules.model_array_type, "ModelArray"))()

    for element ∈ elements
        vals_tuple = (;)
        vals_tuple = setTupleField(vals_tuple, (:zix, (;)))
        vals_tuple = setTupleField(vals_tuple, (:self, (;)))
        vals_tuple = setTupleField(vals_tuple, (:all_components, (;)))
        elSymbol = Symbol(element)
        tmp_elem = (;)
        hlp_elem = (;)
        tmp_states = setTupleField(tmp_states, (elSymbol, (;)))
        hlp_states = setTupleField(hlp_states, (elSymbol, (;)))
        pool_info = getfield(getfield(info.model_structure.pools, element), :components)
        nlayers = Int64[]
        # layer_thicknesses = []
        layer_thicknesses = info.tem.helpers.numbers.num_type[]
        layer = Int64[]
        inits = []
        # inits = info.tem.helpers.numbers.num_type[]
        sub_pool_name = Symbol[]
        main_pool_name = Symbol[]
        main_pools =
            Symbol.(keys(getfield(getfield(info.model_structure.pools, element),
                :components)))
        layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name =
            getPoolInformation(main_pools,
                pool_info,
                layer_thicknesses,
                nlayers,
                layer,
                inits,
                sub_pool_name,
                main_pool_name;
                num_type=info.tem.helpers.numbers.sNT)

        # set empty tuple fields
        tpl_fields = (:components, :zix, :initial_values, :layer_thickness)
        for _tpl ∈ tpl_fields
            tmp_elem = setTupleField(tmp_elem, (_tpl, (;)))
        end
        hlp_elem = setTupleField(hlp_elem, (:layer_thickness, (;)))
        hlp_elem = setTupleField(hlp_elem, (:zix, (;)))
        hlp_elem = setTupleField(hlp_elem, (:components, (;)))
        hlp_elem = setTupleField(hlp_elem, (:all_components, (;)))
        hlp_elem = setTupleField(hlp_elem, (:zeros, (;)))
        hlp_elem = setTupleField(hlp_elem, (:ones, (;)))
        # hlp_elem = setTupleField(hlp_elem, (:vals, (;)))

        # main pools
        for main_pool ∈ main_pool_name
            zix = Int[]
            initial_values = []
            # initial_values = info.tem.helpers.numbers.num_type[]
            components = Symbol[]
            for (ind, par) ∈ enumerate(sub_pool_name)
                if startswith(String(par), String(main_pool))
                    push!(zix, ind)
                    push!(components, sub_pool_name[ind])
                    push!(initial_values, inits[ind])
                end
            end
            initial_values = createArrayofType(initial_values,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)

            zix = Tuple(zix)

            tmp_elem = setTupleSubfield(tmp_elem, :components, (main_pool, Tuple(components)))
            tmp_elem = setTupleSubfield(tmp_elem, :zix, (main_pool, zix))
            tmp_elem = setTupleSubfield(tmp_elem, :initial_values, (main_pool, initial_values))
            hlp_elem = setTupleSubfield(hlp_elem, :zix, (main_pool, zix))
            hlp_elem = setTupleSubfield(hlp_elem, :components, (main_pool, Tuple(components)))
            onetyped = createArrayofType(ones(size(initial_values)),
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)
            # onetyped = ones(length(initial_values))
            hlp_elem = setTupleSubfield(hlp_elem,
                :zeros,
                (main_pool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlp_elem = setTupleSubfield(hlp_elem, :ones, (main_pool, onetyped))
            # hlp_elem = setTupleSubfield(hlp_elem, :zeros, (main_pool, zeros(initial_values)))
        end

        # subpools
        unique_sub_pools = Symbol[]
        for _sp ∈ sub_pool_name
            if _sp ∉ unique_sub_pools
                push!(unique_sub_pools, _sp)
            end
        end
        for sub_pool ∈ unique_sub_pools
            zix = Int[]
            initial_values = []
            # initial_values = info.tem.helpers.numbers.num_type[]
            components = Symbol[]
            ltck = info.tem.helpers.numbers.num_type[]
            # ltck = []
            for (ind, par) ∈ enumerate(sub_pool_name)
                if par == sub_pool
                    push!(zix, ind)
                    push!(initial_values, inits[ind])
                    push!(components, sub_pool_name[ind])
                    push!(ltck, layer_thicknesses[ind])
                end
            end
            zix = Tuple(zix)
            initial_values = createArrayofType(initial_values,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)
            tmp_elem = setTupleSubfield(tmp_elem, :components, (sub_pool, Tuple(components)))
            tmp_elem = setTupleSubfield(tmp_elem, :zix, (sub_pool, zix))
            tmp_elem = setTupleSubfield(tmp_elem, :initial_values, (sub_pool, initial_values))
            tmp_elem = setTupleSubfield(tmp_elem, :layer_thickness, (sub_pool, Tuple(ltck)))
            hlp_elem = setTupleSubfield(hlp_elem, :layer_thickness, (sub_pool, Tuple(ltck)))
            hlp_elem = setTupleSubfield(hlp_elem, :zix, (sub_pool, zix))
            hlp_elem = setTupleSubfield(hlp_elem, :components, (sub_pool, Tuple(components)))
            onetyped = createArrayofType(ones(size(initial_values)),
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)
            # onetyped = ones(length(initial_values))
            hlp_elem = setTupleSubfield(hlp_elem, :zeros,
                (sub_pool, onetyped .* info.tem.helpers.numbers.𝟘))
            hlp_elem = setTupleSubfield(hlp_elem, :ones, (sub_pool, onetyped))
        end

        ## combined pools
        combine_pools = (getfield(getfield(info.model_structure.pools, element), :combine))
        do_combine = true
        tmp_elem = setTupleField(tmp_elem, (:combine, (; docombine=true, pool=Symbol(combine_pools))))
        if do_combine
            combined_pool_name = Symbol.(combine_pools)
            create = Symbol[combined_pool_name]
            components = Symbol[]
            for _sp ∈ sub_pool_name
                if _sp ∉ components
                    push!(components, _sp)
                end
            end
            # components = Set(Symbol.(sub_pool_name))
            initial_values = inits
            initial_values = createArrayofType(initial_values,
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)
            zix = collect(1:1:length(main_pool_name))
            zix = Tuple(zix)

            tmp_elem = setTupleSubfield(tmp_elem, :components, (combined_pool_name, Tuple(components)))
            tmp_elem = setTupleSubfield(tmp_elem, :zix, (combined_pool_name, zix))
            tmp_elem = setTupleSubfield(tmp_elem, :initial_values, (combined_pool_name, initial_values))
            hlp_elem = setTupleSubfield(hlp_elem, :zix, (combined_pool_name, zix))
            onetyped = createArrayofType(ones(size(initial_values)),
                Nothing[],
                info.tem.helpers.numbers.sNT,
                nothing,
                true,
                model_array_type)
            all_components = Tuple([_k for _k in keys(tmp_elem.zix) if _k !== combined_pool_name])
            hlp_elem = setTupleSubfield(hlp_elem, :all_components, (combined_pool_name, all_components))
            vals_tuple = setTupleSubfield(vals_tuple, :zix, (combined_pool_name, Val(hlp_elem.zix)))
            vals_tuple = setTupleSubfield(vals_tuple, :self, (combined_pool_name, Val(combined_pool_name)))
            vals_tuple = setTupleSubfield(vals_tuple, :all_components, (combined_pool_name, Val(all_components)))
            # hlp_elem = setTupleField(hlp_elem, (:vals, vals_tuple))
            hlp_elem = setTupleSubfield(hlp_elem, :components, (combined_pool_name, Tuple(components)))
            # onetyped = ones(length(initial_values))
            hlp_elem = setTupleSubfield(hlp_elem,
                :zeros,
                (combined_pool_name, onetyped .* info.tem.helpers.numbers.𝟘))
            hlp_elem = setTupleSubfield(hlp_elem, :ones, (combined_pool_name, onetyped))
        else
            create = Symbol.(unique_sub_pools)
        end

        # check if additional variables exist
        if hasproperty(getfield(info.model_structure.pools, element), :state_variables)
            state_variables = getfield(getfield(info.model_structure.pools, element), :state_variables)
            tmp_elem = setTupleField(tmp_elem, (:state_variables, state_variables))
        end
        arraytype = :view
        if hasproperty(info.experiment.exe_rules, :model_array_type)
            arraytype = Symbol(info.experiment.exe_rules.model_array_type)
        end
        tmp_elem = setTupleField(tmp_elem, (:arraytype, arraytype))
        tmp_elem = setTupleField(tmp_elem, (:create, create))
        tmp_states = setTupleField(tmp_states, (elSymbol, tmp_elem))
        hlp_states = setTupleField(hlp_states, (elSymbol, hlp_elem))
    end
    hlp_new = (;)
    # tcPrint(hlp_states)
    eleprops = propertynames(hlp_states)
    if :carbon in eleprops && :water in eleprops
        for prop ∈ propertynames(hlp_states.carbon)
            cfield = getproperty(hlp_states.carbon, prop)
            wfield = getproperty(hlp_states.water, prop)
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
        hlp_new = hlp_states.carbon
    elseif :carbon ∉ eleprops && :water in eleprops
        hlp_new = hlp_states.water
    else
        hlp_new = hlp_states
    end
    # hlt_new = setTupleField(hlp_new, (:vals, hlp_states.vals))
    info = (; info..., pools=tmp_states)
    # info = (; info..., tem=(; info.tem..., pools=tmp_states))
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlp_new)))
    # info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., pools=hlp_states)))
    return info
end


"""
    getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)

returns a named tuple with initial pool variables as subfields that is used in out.pools. Uses @view to create components of pools as a view of main pool that just references the original array.
"""

"""
    getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)


"""
function getInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)
    init_pools = (;)
    for element ∈ propertynames(info_pools)
        props = getfield(info_pools, element)
        model_array_type = getfield(SindbadSetup, toUpperCaseFirst(string(getfield(props, :arraytype)), "ModelArray"))()
        var_to_create = getfield(props, :create)
        initial_values = getfield(props, :initial_values)
        for tocr ∈ var_to_create
            input_values = deepcopy(getfield(initial_values, tocr))
            init_pools = setTupleField(init_pools,
                (tocr,
                    createArrayofType(input_values,
                        Nothing[],
                        tem_helpers.numbers.sNT,
                        nothing,
                        true,
                        model_array_type)))
        end
        to_combine = getfield(getfield(info_pools, element), :combine)
        if to_combine.docombine
            combined_pool_name = to_combine.pool
            zix_pool = getfield(props, :zix)
            components = keys(zix_pool)
            pool_array = getfield(init_pools, combined_pool_name)
            for component ∈ components
                if component != combined_pool_name
                    indx = getfield(zix_pool, component)
                    input_values = deepcopy(getfield(initial_values, component))
                    compdat = createArrayofType(input_values,
                        pool_array,
                        tem_helpers.numbers.sNT,
                        indx,
                        false,
                        model_array_type)
                    init_pools = setTupleField(init_pools, (component, compdat))
                end
            end
        end
    end
    return init_pools
end

"""
    getInitStates(info)

returns a named tuple with initial state variables as subfields that is used in out.states. Extended from getInitPools, it uses @view to create components of states as a view of main state that just references the original array. The states to be intantiate are taken from state_variables in model_structure.json. The entries their are prefix to parent pool, when the state variables are created.
"""

"""
    getInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)


"""
function getInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)
    initial_states = (;)
    for element ∈ propertynames(info_pools)
        props = getfield(info_pools, element)
        var_to_create = getfield(props, :create)
        additional_state_vars = getfield(props, :state_variables)
        initial_values = getfield(props, :initial_values)
        model_array_type = getfield(SindbadSetup, toUpperCaseFirst(string(getfield(props, :arraytype)), "ModelArray"))()
        for tocr ∈ var_to_create
            for avk ∈ keys(additional_state_vars)
                avv = getproperty(additional_state_vars, avk)
                Δtocr = Symbol(string(avk) * string(tocr))
                vals =
                    zero(getfield(initial_values, tocr)) .+ tem_helpers.numbers.𝟙 *
                                                      tem_helpers.numbers.sNT(avv)
                newvals = createArrayofType(vals,
                    Nothing[],
                    tem_helpers.numbers.sNT,
                    nothing,
                    true,
                    model_array_type)
                initial_states = setTupleField(initial_states, (Δtocr, newvals))
            end
        end
        to_combine = getfield(getfield(info_pools, element), :combine)
        if to_combine.docombine
            combined_pool_name = Symbol(to_combine.pool)
            for avk ∈ keys(additional_state_vars)
                avv = getproperty(additional_state_vars, avk)
                Δ_combined_pool_name = Symbol(string(avk) * string(combined_pool_name))
                zix_pool = getfield(props, :zix)
                components = keys(zix_pool)
                Δ_pool_array = getfield(initial_states, Δ_combined_pool_name)
                for component ∈ components
                    if component != combined_pool_name
                        Δ_component = Symbol(string(avk) * string(component))
                        indx = getfield(zix_pool, component)
                        Δ_compdat = createArrayofType((zero(getfield(initial_values, component)) .+ tem_helpers.numbers.𝟙) .*
                                                     tem_helpers.numbers.sNT(avv),
                            Δ_pool_array,
                            tem_helpers.numbers.sNT,
                            indx,
                            false,
                            model_array_type)
                        # Δ_compdat::AbstractArray = @view Δ_pool_array[indx]
                        initial_states = setTupleField(initial_states, (Δ_component, Δ_compdat))
                    end
                end
            end
        end
    end
    return initial_states
end


"""
    getModelRunInfo(info::NamedTuple)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved
"""
function getModelRunInfo(info::NamedTuple)
    if info.experiment.flags.run_optimization
        info = @set info.experiment.flags.catch_model_errors = false
    end
    run_vals = convertRunFlagsToTypes(info)
    output_array_type = getfield(SindbadSetup, toUpperCaseFirst(info.experiment.model_output.output_array_type, "Output"))()
    run_info = (; run_vals..., output_array_type = output_array_type)
    run_info = setTupleField(run_info, (:save_single_file, getTypeInstanceForFlags(:save_single_file, info.experiment.model_output.save_single_file, "Do")))
    run_info = setTupleField(run_info, (:use_forward_diff, run_vals.use_forward_diff))
    parallelization = titlecase(info.experiment.exe_rules.parallelization)
    run_info = setTupleField(run_info, (:parallelization, getfield(SindbadSetup, Symbol("Use"*parallelization*"Parallelization"))()))
    land_output_type = getfield(SindbadSetup, toUpperCaseFirst(info.experiment.exe_rules.land_output_type, "LandOut"))()
    run_info = setTupleField(run_info, (:land_output_type, land_output_type))
    return run_info
end

"""
    getNumberType(t::String)

A helper function to get the number type from the specified string
"""
function getNumberType(t::String)
    ttype = eval(Meta.parse(t))
    return ttype
end

"""
    getNumberType(t::DataType)

A helper function to get the number type from the specified string
"""
function getNumberType(t::DataType)
    return t
end


"""
    getOrderedOutputList(varlist, var_o::Symbol)

return the corresponding variable from the full list

# Arguments:
- `varlist`: the full variable list 
- `var_o`: the variable to find
"""
function getOrderedOutputList(varlist, var_o::Symbol)
    for var ∈ varlist
        vname = Symbol(split(string(var), '.')[end])
        if vname === var_o
            return var
        end
    end
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
    order_selected_models = []
    for msm ∈ all_sindbad_models_reordered
        if msm in selected_models
            push!(order_selected_models, msm)
        end
    end

    return order_selected_models
end

"""
    getParameters(selected_models)


"""
function getParameters(selected_models_in::LongTuple, num_type; return_table=true)
    selected_models = getTupleFromLongTable(selected_models_in)
    return getParameters(selected_models, num_type; return_table=return_table)
end

"""
    getParameters(selected_models)


"""
function getParameters(selected_models::Tuple, num_type; return_table=true)
    model_names_list = nameof.(typeof.(selected_models));
    default = [flatten(selected_models)...]
    constrains = metaflatten(selected_models, Models.bounds)
    nbounds = length(constrains)
    lower = [constrains[i][1] for i ∈ 1:nbounds]
    upper = [constrains[i][2] for i ∈ 1:nbounds]
    name = [fieldnameflatten(selected_models)...] # SVector(flatten(x))
    model_approach = [parentnameflatten(selected_models)...]
    model = [Symbol(supertype(getproperty(Models, m))) for m ∈ model_approach]
    name_full = [join((model[i], name[i]), ".") for i ∈ 1:nbounds]
    approach_func = [getfield(Models, m) for m ∈ model_approach]
    model_prev = model_approach[1]
    m_id = findall(x-> x==model_prev, model_names_list)[1]
    model_id = map(model_approach) do m
        if m !== model_prev
            model_prev = m
            m_id = findall(x-> x==model_prev, model_names_list)[1]
        end
        m_id
    end
    # default = num_type.(default)
    lower = num_type.(lower)
    upper = num_type.(upper)
    output = (;
    model_id,
    name,
    default,
    optim=default,
    lower,
    upper,
    model,
    model_approach,
    approach_func,
    name_full)
    output = return_table ? Table(output) : output
    return output
end


"""
    getParameters(selected_models, model_parameter_default)

retrieve all model parameters
"""
function getParameters(selected_models, model_parameter_default, num_type)
    models_tuple = getParameters(selected_models, num_type; return_table=false)
    default = models_tuple.default
    model_approach = models_tuple.model_approach
    dp_dist = typeof(default[1]).(model_parameter_default[:distribution][2])
    dist = [model_parameter_default[:distribution][1] for m ∈ model_approach]
    p_dist = [dp_dist for m ∈ model_approach]
    is_ml = [model_parameter_default.is_ml for m ∈ model_approach]
    return Table(; models_tuple... ,dist, p_dist, is_ml)
end

"""
    getParameters(selected_models, model_parameter_default, opt_parameter::Vector)



# Arguments:
- `selected_models`: DESCRIPTION
- `model_parameter_default`: DESCRIPTION
- `opt_parameter`: DESCRIPTION
"""
function getParameters(selected_models, model_parameter_default, opt_parameter::Vector, num_type)
    opt_parameter = replaceCommaSeparatorParams(opt_parameter)
    tbl_parameters = getParameters(selected_models, model_parameter_default, num_type)
    return filter(row -> row.name_full in opt_parameter, tbl_parameters)
end

"""
    getParameters(selected_models, model_parameter_default, opt_parameter::NamedTuple)



# Arguments:
- `selected_models`: DESCRIPTION
- `model_parameter_default`: DESCRIPTION
- `opt_parameter`: DESCRIPTION
"""
function getParameters(selected_models, model_parameter_default, opt_parameter::NamedTuple, num_type)
    param_list = replaceCommaSeparatorParams(keys(opt_parameter))
    tbl_parameters = getParameters(selected_models, model_parameter_default, param_list, num_type)
    tbl_parameters_filtered = filter(row -> row.name_full in param_list, tbl_parameters)
    new_dist = tbl_parameters_filtered.dist
    new_p_dist = tbl_parameters_filtered.p_dist
    new_is_ml = tbl_parameters_filtered.is_ml
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
    tbl_parameters_filtered.is_ml .= new_is_ml
    tbl_parameters_filtered.dist .= new_dist
    tbl_parameters_filtered.p_dist .= new_p_dist
    return tbl_parameters_filtered
end


"""
    getPoolInformation(main_pools, pool_info, layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name; prename="", num_type=Float64)

A helper function to get the information of each pools from info.model_structure.pools and puts them into arrays of information needed to instantiate pool variables.
"""

"""
    getPoolInformation(main_pools, pool_info, layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name; prename = , num_type = Float64)



# Arguments:
- `main_pools`: DESCRIPTION
- `pool_info`: DESCRIPTION
- `layer_thicknesses`: DESCRIPTION
- `nlayers`: DESCRIPTION
- `layer`: DESCRIPTION
- `inits`: DESCRIPTION
- `sub_pool_name`: DESCRIPTION
- `main_pool_name`: DESCRIPTION
- `prename`: DESCRIPTION
- `num_type`: DESCRIPTION
"""
function getPoolInformation(main_pools,
    pool_info,
    layer_thicknesses,
    nlayers,
    layer,
    inits,
    sub_pool_name,
    main_pool_name;
    prename="",
    num_type=Float64)
    for main_pool ∈ main_pools
        prefix = prename
        main_pool_info = getproperty(pool_info, main_pool)
        if !isa(main_pool_info, NamedTuple)
            if isa(main_pool_info[1], Number)
                lenpool = main_pool_info[1]
                # layer_thickness = repeat([nothing], lenpool)
                layer_thickness = (main_pool_info[1])
            else
                lenpool = length(main_pool_info[1])
                layer_thickness = (main_pool_info[1])
            end

            append!(layer_thicknesses, layer_thickness)
            append!(nlayers, fill(1, lenpool))
            append!(layer, collect(1:lenpool))
            append!(inits, fill((main_pool_info[2]), lenpool))

            if prename == ""
                append!(sub_pool_name, fill(main_pool, lenpool))
                append!(main_pool_name, fill(main_pool, lenpool))
            else
                append!(sub_pool_name, fill(Symbol(String(prename) * string(main_pool)), lenpool))
                append!(main_pool_name, fill(Symbol(String(prename)), lenpool))
            end
        else
            prefix = prename * String(main_pool)
            sub_pools = propertynames(main_pool_info)
            layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name =
                getPoolInformation(sub_pools,
                    main_pool_info,
                    layer_thicknesses,
                    nlayers,
                    layer,
                    inits,
                    sub_pool_name,
                    main_pool_name;
                    prename=prefix)
        end
    end
    return layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name
end

"""
    getRestartFilePath(info::NamedTuple)

Checks if the restartFile in experiment.model_spinup is an absolute path. If not, uses experiment_root as the base path to create an absolute path for loadSpinup, and uses output.root as the base for saveSpinup
"""
function getRestartFilePath(info::NamedTuple)
    restart_file_in = info.experiment.model_spinup.restart_file
    restart_file = nothing

    if !isnothing(restart_file_in)
        if restart_file_in[(end-4):end] != ".jld2"
            error(
                "info.experiment.model_spinup.restartFile has a file ending other than .jld2. Only jld2 files are supported for loading spinup. Either give a correct file or set info.experiment.flags.load_spinup to false."
            )
        end
        if isabspath(restart_file_in)
            restart_file = restart_file_in
        else
            restart_file = joinpath(info.experiment_root, restart_file_in)
        end
        info = @set info.experiment.model_spinup.restart_file = restart_file
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
    selected_approach_forward = ()
    selected_approach_spinup = ()
    is_spinup = Int64[]
    order_selected_models = info.tem.models.selected_models.model
    default_model = getfield(info.model_structure, :default_model)
    for sm ∈ order_selected_models
        model_info = getfield(info.model_structure.models, sm)
        selected_approach = model_info.approach
        selected_approach = String(sm) * "_" * selected_approach
        selected_approach_func = getTypedModel(Symbol(selected_approach), info.tem.helpers.numbers.sNT)
        # selected_approach_func = getfield(Sindbad.Models, Symbol(selected_approach))()
        selected_approach_forward = (selected_approach_forward..., selected_approach_func)
        if :use_in_spinup in propertynames(model_info)
            use_in_spinup = model_info.use_in_spinup
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
    if hasproperty(info, :parameters) && !isempty(info.parameters)
        original_params_forward = getParameters(selected_approach_forward)
        input_params = info.parameters
        updated_params = setInputParameters(original_params_forward, input_params)
        selected_approach_forward = updateModelParameters(updated_params, selected_approach_forward)
    end
    info = (; info..., tem=(; info.tem..., models=(; info.tem.models..., forward=selected_approach_forward, is_spinup=is_spinup))) 
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
    getTypeInstanceForFlags(mode_name)

a helper function to get the type for boolean flags. In this, the names are converted to string, split by "_", and prefixed to generate a true and false case type
"""
function getTypeInstanceForFlags(option_name::Symbol, option_value, opt_pref="Do")
    opt_s = string(option_name)
    structname = toUpperCaseFirst(opt_s, opt_pref)
    if !option_value
        structname = toUpperCaseFirst(opt_s, opt_pref*"Not")
    end
    struct_instance = getfield(SindbadSetup, structname)()
    return struct_instance
end


"""
    getTypeInstanceForNamedOptions(::String)

a helper function to get the type for named option with string values. In this, the string is split by "_" and join after capitalizing the first letter
"""
function getTypeInstanceForNamedOptions(option_name::String)
    opt_ss = toUpperCaseFirst(option_name)
    struct_instance = getfield(SindbadSetup, opt_ss)()
    return struct_instance
end


"""
    getTypeInstanceForNamedOptions(option_name::Symbol)

a helper function to get the type for named option with string values. In this, the option name is converted to string, and the function for string type is called
"""
function getTypeInstanceForNamedOptions(option_name::Symbol)
    getTypeInstanceForNamedOptions(string(option_name))
    return struct_instance
end

"""
    getVariableGroups(var_list::AbstractArray)

get named tuple for variables groups from list of variables. Assumes that the entries in the list follow subfield.variablename of model output (land
"""
function getVariableGroups(var_list::AbstractArray)
    var_dict = Dict()
    for var ∈ var_list
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
    getVariablePair(out_var)

return a vector of pairs with field and subfield of land from the list of variables (output_vars) in field.subfield convention
"""
function getVariablePair(out_var::String)
    sep = "."
    if occursin(",", out_var)
        sep = ","
    end
    return Tuple(Symbol.(split(string(out_var), sep)))
end


"""
    getVariablePair(out_var)

return a vector of pairs with field and subfield of land from the list of variables (output_vars) in field.subfield convention
"""
function getVariablePair(out_var::Symbol)
    getVariablePair(string(out_var))
end

"""
    getVariablesToStore(info::NamedTuple)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved
"""
function getVariablesToStore(info::NamedTuple)
    output_vars = collect(propertynames(info.experiment.model_output.variables))
    out_vars_pairs = Tuple(getVariablePair.(output_vars))
    info = (; info..., tem=(; info.tem..., variables=out_vars_pairs))
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
    if occursin("ForwardDiff.Dual", info.experiment.exe_rules.model_number_type)
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


"""
function splitRenameParam(_p::Symbol, _splitter)
    p_string = String(_p)
    return splitRenameParam(p_string, _splitter)
end

"""
    splitRenameParam(p_string::String, _splitter)


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
function setNumericHelpers(info::NamedTuple, ttype=info.experiment.exe_rules.model_number_type)
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
    seqq_typed = []
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
                seq["aggregator_indices"] = [_ind for _ind in vcat(aggregator[1].indices...)]
                seq["n_timesteps"] = length(aggregator[1].indices)
                if occursin("_year", seq[kk])
                    seq["aggregator_type"] = TimeIndexed()
                    seq["n_timesteps"] = length(seq["aggregator_indices"])
                end
            end
            if kk == "spinup_mode"
                seq[kk] = getTypeInstanceForNamedOptions(seq[kk])
            end
            if seq[kk] isa String
                seq[kk] = Symbol(seq[kk])
            end
        end
        optns = in(seq, "options") ? seqp["options"] : (;)
        sst = SpinSequenceWithAggregator(seq["forcing"], seq["n_repeat"], seq["n_timesteps"], seq["spinup_mode"], optns, seq["aggregator_indices"], seq["aggregator"], seq["aggregator_type"]);
        push!(seqq_typed, sst)
    end
    
    infospin = setTupleField(infospin, (:sequence, [_s for _s in seqq_typed]))
    info = setTupleSubfield(info, :tem, (:spinup, infospin))
    return info
end

"""
    setupInfo(info::NamedTuple)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function setupInfo(info::NamedTuple)
    @info "  setupInfo: setting Numeric Helpers..."
    info = setNumericHelpers(info)
    @info "  setupInfo: setting Output Helpers..."
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., output=info.output)))
    @info "  setupInfo: setting Pools Info..."
    info = generatePoolsInfo(info)
    @info "  setupInfo: setting Dates Helpers..."
    info = generateDatesInfo(info)
    selected_models = collect(propertynames(info.model_structure.models))
    # @show sel
    # selected_models = (selected_models..., :dummy)
    @info "  setupInfo: setting Model Structure..."
    selected_models = getOrderedSelectedModels(info, selected_models)
    info = (;
        info...,
        tem=(;
            info.tem...,
            models=(; selected_models=Table((; model=[selected_models...])))))
    info = getSpinupAndForwardModels(info)
    @info "  setupInfo:         ...saving Selected Models Code..."
    _ = parseSaveCode(info)

    # add information related to model run
    @info "  setupInfo: setting Model Run Flags..."
    run_info = getModelRunInfo(info)
    info = (; info..., tem=(; info.tem..., helpers=(; info.tem.helpers..., run=run_info)))
    @info "  setupInfo: setting Spinup Info..."
    info = setSpinupInfo(info)

    @info "  setupInfo: setting Variable Helpers..."
    info = getVariablesToStore(info)

    if info.experiment.flags.run_optimization || info.experiment.flags.calc_cost
        @info "  setupInfo: setting Optimization and Observation info..."
        info = setupOptimization(info)
    end

    if !isnothing(info.experiment.exe_rules.longtuple_size)
        selected_approach_forward = makeLongTuple(info.tem.models.forward, info.experiment.exe_rules.longtuple_size)
        info = @set info.tem.models.forward = selected_approach_forward
    end
    return info
end

