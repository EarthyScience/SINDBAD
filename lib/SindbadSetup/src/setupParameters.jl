export getParameters

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
