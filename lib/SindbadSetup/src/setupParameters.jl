export getOptimizationParametersTable
export getParameters
export getParameterIndices


"""
    getParameters(selected_models::Tuple, num_type, model_timestep; return_table=true)
    getParameters(selected_models::LongTuple, num_type, model_timestep; return_table=true)
Retrieves parameters for the specified models with given numerical type and timestep settings. 

# Arguments
- `selected_models`: A collection of selected models
    - `::Tuple`: as a tuple 
    - `::LongTuple`: as a long tuple
- `num_type`: The numerical type to be used for parameters
- `model_timestep`: The timestep setting for the model simulation
- `return_table::Bool=true`: Whether to return results in table format

# Returns
Parameters information for the selected models based on the specified settings.
"""
getParameters

function getParameters(selected_models::LongTuple, num_type, model_timestep; return_table=true, show_info=false)
    selected_models = getTupleFromLongTuple(selected_models)
    return getParameters(selected_models, num_type, model_timestep; return_table=return_table, show_info=show_info)
end

function getParameters(selected_models::Tuple, num_type, model_timestep; return_table=true, show_info=false)
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
    checkParameterBounds(name, default, lower, upper, ScaleNone(),show_info=show_info, model_names=model_approach)
    output = (; model_id, name, default, optim=default, lower, upper, timescale_run=timescale_run, units=unts, timescale_ori=timescale, units_ori=unts_ori, model, model_approach, approach_func, name_full)
    output = return_table ? Table(output) : output
    return output
end

"""
    getOptimizationParametersTable(tbl_parameters_all::Table, model_parameter_default, optimization_parameters)

Creates a filtered and enhanced parameter table for optimization by combining input parameters with default model parameters with the table of all parameters in the selected model structure.

# Arguments
- `tbl_parameters_all::Table`: A table containing all model parameters
- `model_parameter_default`: Default parameter settings including distribution and a flag differentiating if the parameter is to be ML-parameter-learnt
- `optimization_parameters`: Parameters to be optimized, specified either as:
    - `::NamedTuple`: Named tuple with parameter configurations
    - `::Vector`: Vector of parameter names to use with default settings

# Returns
A filtered `Table` containing only the optimization parameters, enhanced with:
- `is_ml`: Boolean flag indicating if parameter uses machine learning
- `dist`: Distribution type for each parameter
- `p_dist`: Distribution parameters as an array of numeric values

# Notes
- Parameters can be specified using comma-separated strings for model.parameter pairs
- For NamedTuple inputs, individual parameter configurations override model_parameter_default
- The output table preserves the numeric type of the input parameters
"""
function getOptimizationParametersTable(tbl_parameters_all::Table, model_parameter_default, optimization_parameters)
    param_list = []
    param_keys = []
    if isa(optimization_parameters, NamedTuple)
        param_list = replaceCommaSeparatedParams(keys(optimization_parameters))
        param_keys = keys(optimization_parameters)
    else
        param_list = replaceCommaSeparatedParams(optimization_parameters)
        param_keys = optimization_parameters
    end
    tbl_parameters_all_filtered = filter(row -> row.name_full in param_list, tbl_parameters_all)
    num_type = typeof(tbl_parameters_all_filtered.default[1])
    tuple_parameters = getNamedTupleFromTable(tbl_parameters_all_filtered, replace_missing_values=true)
    p_ind = 1
    is_ml = Array{Bool}(undef, length(param_list))
    dist = Array{String}(undef, length(param_list))
    p_dist = Array{Array{num_type,1}}(undef, length(param_list))
    for (p_ind, p_key) ∈ enumerate(param_keys)
        p_field = nothing
        if isa(optimization_parameters, NamedTuple)
            p_field = getproperty(optimization_parameters, p_key)
            if isnothing(p_field)
                p_field = model_parameter_default
            end
        else
            p_field = model_parameter_default
        end
        is_ml[p_ind] = getproperty(p_field, :is_ml)
        nd = getproperty(p_field, :distribution)
        dist[p_ind] = nd[1]
        p_dist[p_ind] = [num_type.(nd[2])...]
    end
    tuple_parameters =setTupleField(tuple_parameters, (:is_ml, is_ml))
    tuple_parameters =setTupleField(tuple_parameters, (:dist, dist))
    tuple_parameters =setTupleField(tuple_parameters, (:p_dist, p_dist))
    return Table(tuple_parameters)
end


"""
    getModelParameterIndices(model, table_parameters::Table, r)

Retrieves indices for model parameters from a parameter table.

# Arguments

- `model`: A model object for which parameters are being indexed
- `table_parameters::Table`: Table containing parameter information
- `r`: Row index or identifier for the specific parameter set

# Returns
Indices corresponding to the model parameters in the parameter table for a model.
"""
function getModelParameterIndices(model, table_parameters::Table, r)
    modelName = nameof(typeof(model))
    empty!(r)
    for var in propertynames(model)

        pindex = findfirst(row -> row.name == var && row.model_approach == modelName, table_parameters)
        if !isnothing(pindex)
            push!(r, var => pindex)
        end
    end
    NamedTuple((modelName => NamedTuple(r),))
end


"""
    getParameterIndices(selected_models::LongTuple, table_parameters::Table)
    getParameterIndices(selected_models::Tuple, table_parameters::Table)

Retrieves indices for model parameters from a parameter table.

# Arguments
- `selected_models`
    - `::LongTuple`: A long tuple of selected models
    - `::Tuple`: A tuple of selected models
- `table_parameters::Table`: Table containing parameter information

# Returns
A Tuple of Pair of Name and Indices corresponding to the model parameters in the parameter table for  selected models.
"""
getModelParameterIndices

function getParameterIndices(selected_models::LongTuple, table_parameters::Table)
    selected_models_tuple = getTupleFromLongTuple(selected_models)
    return getParameterIndices(selected_models_tuple, table_parameters)
end

function getParameterIndices(selected_models::Tuple, table_parameters::Table)
    r = (;)
    tempvec = Pair{Symbol,Int}[]
    for m in selected_models
        r = (; r..., getModelParameterIndices(m, table_parameters, tempvec)...)
    end
    r
end


"""
    replaceCommaSeparatedParams(p_names_list)

get a list/vector of parameters in which each parameter string is split with comma to separate model name and parameter name
"""
function replaceCommaSeparatedParams(p_names_list)
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
- `p_string`: The input parameter to be split and renamed
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
            upoTable.upper[pindx] = updated_table.upper[i]
            upoTable.lower[pindx] = updated_table.lower[i]
        end
    end
    return upoTable
end
