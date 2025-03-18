
export scaleParameters
export deScaleParameters
export updateModelParameters


"""
    deScaleParameters(param_vector_scaled, tbl_params, <:SindbadParameterScaling)

Reverts scaling of parameters using a specified scaling strategy.

# Arguments
- `param_vector_scaled`: Vector of scaled parameters to be converted back to original scale
- `tbl_params`: Table containing parameter information and scaling factors
- `SindbadParameterScaling`: Type indicating the scaling strategy to be used
    - `::ScaleByDefault`: Type indicating scaling by default values
    - `::ScaleByBounds`: Type indicating scaling by parameter bounds
    - `::DoNotScale`: Type indicating no scaling should be applied (parameters remain unchanged)

# Returns
Returns the unscaled/actual parameter vector in original units.
"""
deScaleParameters

function deScaleParameters(param_vector_scaled, tbl_params, ::DoNotScale)
    return param_vector_scaled
end
    
function deScaleParameters(param_vector_scaled, tbl_params, ::ScaleByDefault)
    param_vector_scaled .= tbl_params.default .* param_vector_scaled
    return param_vector_scaled
end

function deScaleParameters(param_vector_scaled, tbl_params, ::ScaleByBounds)
    ub = tbl_params.upper  # upper bounds
    lb = tbl_params.lower   # lower bounds
    param_vector_scaled .= lb + (ub - lb) * param_vector_scaled
    return param_vector_scaled
end


"""
    scaleParameters(tbl_params, <:SindbadParameterScaling)

Scale parameters from the input table using default scaling factors.

# Arguments
- `tbl_params`: Table containing parameters to be scaled
- `SindbadParameterScaling`: Type indicating the scaling strategy to be used
    - `::ScaleDefault`: Type indicating scaling by default values
    - `::ScaleBounds`: Type parameter indicating scaling by parameter bounds 
    - `::DoNotScale`: Type parameter indicating no scaling should be applied


# Returns
Scaled parameters and their bounds according to default scaling factors
"""
scaleParameters

function scaleParameters(tbl_params, ::DoNotScale)
    default = tbl_params.default
    ub = tbl_params.upper  # upper bounds
    lb = tbl_params.lower   # lower bounds
    return (default, lb, ub)
end
    
function scaleParameters(tbl_params, ::ScaleDefault)
    default = tbl_params.default
    default = default ./ default
    ub = tbl_params.upper ./ default   # upper bounds
    lb = tbl_params.lower ./ default   # lower bounds
    return (default, lb, ub)
end

function scaleParameters(tbl_params, ::ScaleBounds)
    default = tbl_params.default
    ub = tbl_params.upper  # upper bounds
    lb = tbl_params.lower   # lower bounds
    scalar_def = default - lb  / (ub - lb)
    lb = zero(lb)
    ub = ones(ub) 
    return (scalar_def, lb, ub)
end



"""
    updateModelParameters(tbl_params, selected_models::Tuple, param_vector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: a vector of parameter values to update the models
"""
function updateModelParameters(tbl_params::Table, selected_models_in::LongTuple, param_vector::AbstractArray)
    selected_models = getTupleFromLongTuple(selected_models_in)
    return updateModelParameters(tbl_params, selected_models, param_vector)
end


"""
    updateModelParameters(tbl_params, selected_models::Tuple, param_vector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: a vector of parameter values to update the models
"""
function updateModelParameters(tbl_params::Table, selected_models::Tuple, param_vector::AbstractArray)
    updatedModels = eltype(selected_models)[]
    namesApproaches = nameof.(typeof.(selected_models)) # a better way to do this?
    for (idx, modelName) ∈ enumerate(namesApproaches)
        approachx = selected_models[idx]
        model_obj = approachx
        newapproachx = if modelName in tbl_params.model_approach
            vars = propertynames(approachx)
            newvals = Pair[]
            for var ∈ vars
                pindex = findall(row -> row.name == var && row.model_approach == modelName,
                    tbl_params)
                pval = getproperty(approachx, var)
                if !isempty(pindex)
                    pval = param_vector[pindex[1]]
                end
                push!(newvals, var => pval)
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
    updateModelParameters(param_to_index::NamedTuple, selected_models, param_vector::AbstractArray)

update models/parameters without mutating the table of parameters

# Arguments:
- `param_to_index`: a NamedTuple matching indices to models
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: a vector of parameter values to update the models
"""
function updateModelParameters(param_to_index::NamedTuple, selected_models, param_vector::AbstractArray)
    map(selected_models) do model
          modelmap = param_to_index[nameof(typeof(model))]
          varsreplace = map(i->param_vector[i],modelmap)
          ConstructionBase.setproperties(model,varsreplace)
    end
end


@generated function updateModelParameters(selected_models, param_vector::AbstractArray, ::Val{p_vals}) where p_vals
    gen_output = quote end
    p_index = 1
    foreach(p_vals) do p
        param = Symbol(split(string(first(p)), "____")[end])
        mod_index = last(p)
        push!(gen_output.args,
            Expr(:(=),
                :selected_models,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., Expr(:ref, :selected_models, mod_index), QuoteNode(param)), Expr(:ref, :param_vector, p_index))))) #= none:1 =#
                    p_index += 1
    end
    return gen_output
end