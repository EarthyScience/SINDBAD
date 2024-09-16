export createInitPools
export createInitStates
export setPoolsInfo

"""
    setPoolsInfo(info::NamedTuple)

generates the info.temp.helpers.pools and info.pools. The first one is used in the models, while the second one is used in instantiating the pools for initial output tuple.

"""
function setPoolsInfo(info::NamedTuple)
    elements = keys(info.settings.model_structure.pools)
    tmp_states = (;)
    hlp_states = (;)
    model_array_type = getfield(SindbadSetup, toUpperCaseFirst(info.settings.experiment.exe_rules.model_array_type, "ModelArray"))()

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
        pool_info = getfield(getfield(info.settings.model_structure.pools, element), :components)
        nlayers = Int64[]
        # layer_thicknesses = []
        layer_thicknesses = info.temp.helpers.numbers.num_type[]
        layer = Int64[]
        inits = []
        # inits = info.temp.helpers.numbers.num_type[]
        sub_pool_name = Symbol[]
        main_pool_name = Symbol[]
        main_pools =
            Symbol.(keys(getfield(getfield(info.settings.model_structure.pools, element),
                :components)))
        layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name =
            getPoolInformation(main_pools,
                pool_info,
                layer_thicknesses,
                nlayers,
                layer,
                inits,
                sub_pool_name,
                main_pool_name)

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
            # initial_values = info.temp.helpers.numbers.num_type[]
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
                info.temp.helpers.numbers.num_type,
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
                info.temp.helpers.numbers.num_type,
                nothing,
                true,
                model_array_type)
            # onetyped = ones(length(initial_values))
            hlp_elem = setTupleSubfield(hlp_elem,
                :zeros,
                (main_pool, zero(onetyped)))
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
            # initial_values = info.temp.helpers.numbers.num_type[]
            components = Symbol[]
            ltck = info.temp.helpers.numbers.num_type[]
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
                info.temp.helpers.numbers.num_type,
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
                info.temp.helpers.numbers.num_type,
                nothing,
                true,
                model_array_type)
            # onetyped = ones(length(initial_values))
            hlp_elem = setTupleSubfield(hlp_elem, :zeros,
                (sub_pool, zero(onetyped)))
            hlp_elem = setTupleSubfield(hlp_elem, :ones, (sub_pool, onetyped))
        end

        ## combined pools
        combine_pools = (getfield(getfield(info.settings.model_structure.pools, element), :combine))
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
                info.temp.helpers.numbers.num_type,
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
                info.temp.helpers.numbers.num_type,
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
                (combined_pool_name, zero(onetyped)))
            hlp_elem = setTupleSubfield(hlp_elem, :ones, (combined_pool_name, onetyped))
        else
            create = Symbol.(unique_sub_pools)
        end

        # check if additional variables exist
        if hasproperty(getfield(info.settings.model_structure.pools, element), :state_variables)
            state_variables = getfield(getfield(info.settings.model_structure.pools, element), :state_variables)
            tmp_elem = setTupleField(tmp_elem, (:state_variables, state_variables))
        end
        arraytype = :view
        if hasproperty(info.settings.experiment.exe_rules, :model_array_type)
            arraytype = Symbol(info.settings.experiment.exe_rules.model_array_type)
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
    info = (; info..., pools=tmp_states, temp=(; info.temp..., helpers=(; info.temp.helpers..., pools=hlp_new)))
    return info
end


"""
    createInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)

returns a named tuple with initial pool variables as subfields that is used in out.pools. Uses @view to create components of pools as a view of main pool that just references the original array.
"""

"""
    createInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)


"""
function createInitPools(info_pools::NamedTuple, tem_helpers::NamedTuple)
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
                        tem_helpers.numbers.num_type,
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
                        tem_helpers.numbers.num_type,
                        indx,
                        false,
                        model_array_type)
                    # Δcomponent = Symbol("Δ" * string(component))
                    init_pools = setTupleField(init_pools, (component, compdat))
                    # init_pools = setTupleField(init_pools, (Δcomponent, zero(compdat)))
                end
            end
        end
    end
    return init_pools
end

"""
    createInitStates(info)

returns a named tuple with initial state variables as subfields that is used in out.states. Extended from createInitPools, it uses @view to create components of states as a view of main state that just references the original array. The states to be intantiate are taken from state_variables in model_structure.json. The entries their are prefix to parent pool, when the state variables are created.
"""
function createInitStates(info_pools::NamedTuple, tem_helpers::NamedTuple)
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
                    one.(getfield(initial_values, tocr)) *
                                                      tem_helpers.numbers.num_type(avv)
                newvals = createArrayofType(vals,
                    Nothing[],
                    tem_helpers.numbers.num_type,
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
                        Δ_compdat = createArrayofType((one.(getfield(initial_values, component))) .*
                                                     tem_helpers.numbers.num_type(avv),
                            Δ_pool_array,
                            tem_helpers.numbers.num_type,
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
    getPoolInformation(main_pools, pool_info, layer_thicknesses, nlayers, layer, inits, sub_pool_name, main_pool_name; prename = "")

A helper function to get the information of each pools from info.settings.model_structure.pools and puts them into arrays of information needed to instantiate pool variables.

# Arguments:
- `main_pools`: list of the main storage pools
- `pool_info`: information of the pools from the input setttings/JSON
- `layer_thicknesses`: the thicknesses of the pools
- `nlayers`: DESCRIPTION
- `layer`: DESCRIPTION
- `inits`: DESCRIPTION
- `sub_pool_name`: DESCRIPTION
- `main_pool_name`: DESCRIPTION
- `prename`: DESCRIPTION
"""
function getPoolInformation(main_pools,
    pool_info,
    layer_thicknesses,
    nlayers,
    layer,
    inits,
    sub_pool_name,
    main_pool_name;
    prename="")
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
