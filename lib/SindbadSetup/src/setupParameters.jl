export getParameters
export getParameterIndices


"""
    getParameters(selected_models::Tuple, num_type, model_timestep; return_table=true)
    getParameters(selected_models::LongTuple, num_type, model_timestep; return_table=true)
    getParameters(selected_models, model_parameter_default::NamedTuple, num_type, model_timestep)
    getParameters(selected_models, model_parameter_default, opt_parameter::Vector, num_type)
    getParameters(selected_models, model_parameter_default, opt_parameter::NamedTuple, num_type)

Retrieves parameters for the specified models with given numerical type and timestep settings.

# Arguments
- `selected_models`: A collection of selected models
    - `::Tuple`: as a tuple 
    - `::LongTuple`: as a long tuple
- `num_type`: The numerical type to be used for parameters
- `model_parameter_default::NamedTuple`: A named tuple containing the default parameters for the models and their distributions
- `opt_parameter::Vector`: A vector containing the names of the parameters to be optimized
- `opt_parameter::NamedTuple`: A named tuple containing the parameters to be optimized with their distributions and whether they are machine learning parameters
- `model_timestep`: The timestep setting for the model simulation
- `return_table::Bool=true`: Whether to return results in table format

# Returns
Parameters configuration for the selected models based on the specified settings.
"""
getParameters

function getParameters(selected_models::LongTuple, num_type, model_timestep; return_table=true)
    selected_models = getTupleFromLongTuple(selected_models)
    return getParameters(selected_models, num_type, model_timestep; return_table=return_table)
end


function getParameters(selected_models::Tuple, num_type, model_timestep; return_table=true)
    model_names_list = nameof.(typeof.(selected_models))
    constrains = []
    default = []
    name = Symbol[]
    model_approach = Symbol[]
    timescale=String[]
    for obj in selected_models
        k_names = propertynames(obj)
        push!(constrains, Models.bounds(obj)...)
        push!(default, [getproperty(obj, name) for name in k_names]...)
        push!(name, k_names...)
        push!(model_approach, repeat([nameof(typeof(obj))], length(k_names))...)
        push!(timescale, Models.timescale(obj)...)
    end
    # infer types by re-building
    constrains = [c for c in constrains]
    default = [d for d in default]

    nbounds = length(constrains)
    lower = [constrains[i][1] for i in 1:nbounds]
    upper = [constrains[i][2] for i in 1:nbounds]
    
    model = [Symbol(supertype(getproperty(Models, m))) for m in model_approach]
    name_full = [join((model[i], name[i]), ".") for i in 1:nbounds]
    approach_func = [getfield(Models, m) for m in model_approach]
    model_prev = model_approach[1]
    m_id = findall(x-> x==model_prev, model_names_list)[1]
    model_id = map(model_approach) do m
        if m !== model_prev
            model_prev = m
            m_id = findall(x-> x==model_prev, model_names_list)[1]
        end
        m_id
    end

    unts=[]
    unts_ori=[]
    for m in eachindex(name)
        prm_name = Symbol(name[m])
        appr = approach_func[m]()
        p_timescale = Sindbad.Models.timescale(appr, prm_name)
        unit_factor = getUnitConversionForParameter(p_timescale, model_timestep)
        lower[m] = lower[m] * unit_factor
        upper[m] = upper[m] * unit_factor
        if hasproperty(appr, prm_name)
            p_unit = Sindbad.Models.units(appr, prm_name)
            push!(unts_ori, p_unit)
            if ~isone(unit_factor)
                p_unit = replace(p_unit, p_timescale => model_timestep)
            end
            push!(unts, p_unit)
        else
            error("$appr does not have a parameter $prmn")
        end
    end

    # default = num_type.(default)
    lower = num_type.(lower)
    upper = num_type.(upper)
    timescale_run = map(timescale) do ts
        isempty(ts) ? ts : model_timestep
    end
    checkParameterBounds(name, default, lower, upper, ScaleNone(),show_info=true, model_names=model_approach)
    output = (; model_id, name, default, optim=default, lower, upper, timescale_run=timescale_run, units=unts, timescale_ori=timescale, units_ori=unts_ori, model, model_approach, approach_func, name_full)
    output = return_table ? Table(output) : output
    return output
end


function getParameters(selected_models, model_parameter_default::NamedTuple, num_type, model_timestep)
    models_tuple = getParameters(selected_models, num_type, model_timestep; return_table=false)
    default = models_tuple.default
    model_approach = models_tuple.model_approach
    dp_dist = typeof(default[1]).(model_parameter_default[:distribution][2])
    dist = [model_parameter_default[:distribution][1] for m ∈ model_approach]
    p_dist = [dp_dist for m ∈ model_approach]
    is_ml = [model_parameter_default.is_ml for m ∈ model_approach]
    return Table(; models_tuple... ,dist, p_dist, is_ml)
end

function getParameters(selected_models, model_parameter_default, opt_parameter::Vector, num_type, model_timestep)
    opt_parameter = replaceCommaSeparatorParams(opt_parameter)
    tbl_parameters = getParameters(selected_models, model_parameter_default, num_type, model_timestep)
    return filter(row -> row.name_full in opt_parameter, tbl_parameters)
end

function getParameters(selected_models, model_parameter_default, opt_parameter::NamedTuple, num_type, model_timestep)
    param_list = replaceCommaSeparatorParams(keys(opt_parameter))
    tbl_parameters = getParameters(selected_models, model_parameter_default, param_list, num_type, model_timestep)
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
    getModelParameterIndices(model, tbl_params::Table, r)

Retrieves indices for model parameters from a parameter table.

# Arguments

- `model`: A model object for which parameters are being indexed
- `tbl_params::Table`: Table containing parameter information
- `r`: Row index or identifier for the specific parameter set

# Returns
Indices corresponding to the model parameters in the parameter table for a model.
"""
function getModelParameterIndices(model, tbl_params::Table, r)
    modelName = nameof(typeof(model))
    empty!(r)
    for var in propertynames(model)

        pindex = findfirst(row -> row.name == var && row.model_approach == modelName, tbl_params)
        if !isnothing(pindex)
            push!(r, var => pindex)
        end
    end
    NamedTuple((modelName => NamedTuple(r),))
end


"""
    getParameterIndices(selected_models::LongTuple, tbl_params::Table)
    getParameterIndices(selected_models::Tuple, tbl_params::Table)

Retrieves indices for model parameters from a parameter table.

# Arguments
- `selected_models`
    - `::LongTuple`: A long tuple of selected models
    - `::Tuple`: A tuple of selected models
- `tbl_params::Table`: Table containing parameter information

# Returns
A Tuple of Pair of Name and Indices corresponding to the model parameters in the parameter table for  selected models.
"""
getModelParameterIndices

function getParameterIndices(selected_models::LongTuple, tbl_params::Table)
    selected_models_tuple = getTupleFromLongTuple(selected_models)
    return getParameterIndices(selected_models_tuple, tbl_params)
end

function getParameterIndices(selected_models::Tuple, tbl_params::Table)
    r = (;)
    tempvec = Pair{Symbol,Int}[]
    for m in selected_models
        r = (; r..., getModelParameterIndices(m, tbl_params, tempvec)...)
    end
    r
end


"""
    replaceCommaSeparatorParams(p_names_list)

get a list/vector of parameters in which each parameter string is split with comma to separate model name and parameter name
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
    splitRenameParam(p_string::String, _splitter)
    splitRenameParam(_p::Symbol, _splitter)

Splits and renames a parameter based on a specified splitter.

# Arguments
- `p_string: The input parameter to be split and renamed
    - `::String`: The parameter string to be split
    - `::Symbol`: The parameter symbol to be split
- `_splitter`: The delimiter used to split the parameter string

# Returns
A tuple containing the split and renamed parameter components.
"""
splitRenameParam

function splitRenameParam(_p::Symbol, _splitter)
    p_string = String(_p)
    return splitRenameParam(p_string, _splitter)
end

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

Updates input parameters by comparing an original table with an updated table from params.json.

# Arguments
- `original_table::Table`: The reference table containing original parameters
- `updated_table::Table`: The table containing updated parameters to be compared with original

# Returns
a merged table with updated parameters
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
            error("model: parameter $(updated_table[i].name) not found in model $(updated_table[i].model). Make sure that the parameter exists in the selected approach for $(updated_table[i].model) or correct the parameter name in params input.")
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
