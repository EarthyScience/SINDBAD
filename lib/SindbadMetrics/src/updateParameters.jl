
export backScaleParameters
export checkParameterBounds
export scaleParameters
export updateModelParameters
export updateModels

"""
    backScaleParameters(param_vector_scaled, tbl_params, <:SindbadParameterScaling)

Reverts scaling of parameters using a specified scaling strategy.

# Arguments
- `param_vector_scaled`: Vector of scaled parameters to be converted back to original scale
- `tbl_params`: Table containing parameter information and scaling factors
- `SindbadParameterScaling`: Type indicating the scaling strategy to be used
    - `::ScaleDefault`: Type indicating scaling by default values
    - `::ScaleBounds`: Type indicating scaling by parameter bounds
    - `::ScaleNone`: Type indicating no scaling should be applied (parameters remain unchanged)

# Returns
Returns the unscaled/actual parameter vector in original units.
"""
backScaleParameters

function backScaleParameters(param_vector_scaled, tbl_params, ::ScaleNone)
    return param_vector_scaled
end
    
function backScaleParameters(param_vector_scaled, tbl_params, ::ScaleDefault)
    param_vector_scaled = abs.(tbl_params.default) .* param_vector_scaled
    return param_vector_scaled
end

function backScaleParameters(param_vector_scaled, tbl_params, ::ScaleBounds)
    ub = tbl_params.upper  # upper bounds
    lb = tbl_params.lower   # lower bounds
    param_vector_scaled .= lb + (ub - lb) .* param_vector_scaled
    return param_vector_scaled
end

"""
    checkInRange(name, value, lower_bound, upper_bound, show_info)

Checks whether a given value or array is within specified bounds.

# Arguments:
- `name`: A string or symbol representing the name or identifier of the parameter being checked.
- `value`: The value or array to be checked against the bounds.
    - Can be a scalar (`Real`) or an array (`AbstractArray`).
- `lower_bound`: The lower bound for the value or array.
- `upper_bound`: The upper bound for the value or array.
- `show_info`: A boolean flag indicating whether to display detailed information about the check.

# Returns:
- `true`: If the value or all elements of the array are within the specified bounds.
- `false`: If the value or any element of the array violates the bounds.

# Notes:
- If `value` is an array and `show_info` is `true`, the function logs a message indicating that the check is skipped for arrays, as bounds are typically defined for scalar parameters.
- For scalar values, the function performs a direct comparison to ensure the value lies within `[lower_bound, upper_bound]`.
- If the bounds are violated, the function logs detailed information (if `show_info` is `true`) and returns `false`.

# Examples:
1. **Checking a scalar value**:
    ```julia
    is_in_range = checkInRange("parameter1", 5.0, 0.0, 10.0, true)
    # Output: true
    ```

2. **Checking an array (skipping bounds check)**:
    ```julia
    is_in_range = checkInRange("parameter2", [1.0, 2.0, 3.0], 0.0, 10.0, true)
    # Output: true (logs a message indicating the check is skipped)
    ```

3. **Checking a scalar value outside bounds**:
    ```julia
    is_in_range = checkInRange("parameter3", -1.0, 0.0, 10.0, true)
    # Output: false (logs a message indicating the violation)
    ```
"""
checkInRange

function checkInRange(n, d::Real, l::Real, u::Real, show_info)
    return l <= d <= u
end

function checkInRange(n, d::AbstractArray, l, u, show_info)
    if show_info
        @info "           $(n) is a matrix parameter. Skipping check as bounds can be numbers and these parameters cannot be optimized by optimizers."
    end
    return true
end


"""
    checkParameterBounds(p_names, default_values, lower_bounds, upper_bounds, _sc::SindbadParameterScaling; show_info=false, model_names=nothing)

Check and display the parameter bounds information for given parameters.

# Arguments
- `p_names`: Names or identifier of the parameters. Vector of strings.
- `default_values`: Default values of the parameters. Vector of Numbers.
- `lower_bounds`: Lower bounds for the parameters. Vector of Numbers.
- `upper_bounds`: Upper bounds for the parameters. Vector of Numbers.
- `_sc::SindbadParameterScaling`: Scaling Type for the parameters
- `show_info`: a flag to display model parameters and their bounds. Boolean.
- `model_names`: Names or identifier of the approaches where the parameters are defined.

# Returns
Displays a formatted output of parameter bounds information or returns an error when they are violated
"""
function checkParameterBounds(p_names, default_values, lower_bounds, upper_bounds, _sc::SindbadParameterScaling; show_info=false, model_names=nothing)
    if show_info
        @info "  Parameters Info: $(nameof(typeof(_sc)))"
    end
    for (i,n) in enumerate(p_names)
        in_range = checkInRange(n, default_values[i], lower_bounds[i], upper_bounds[i], show_info)
        if !in_range
            error("$(String(n)) => $(default_values[i]) [$(lower_bounds[i]), $(upper_bounds[i])] violates the parameter bounds")
        end
        if show_info
            ps = String(n)
            if !isnothing(model_names)
                ps = String(model_names[i]) * " : " * String(n)
            end
            @info "           $(ps) => $(default_values[i]) [$(lower_bounds[i]), $(upper_bounds[i])]"
        end
    end
end



"""
    scaleParameters(tbl_params, <:SindbadParameterScaling)

Scale parameters from the input table using default scaling factors.

# Arguments
- `tbl_params`: Table containing parameters to be scaled
- `SindbadParameterScaling`: Type indicating the scaling strategy to be used
    - `::ScaleDefault`: Type indicating scaling by default values
    - `::ScaleBounds`: Type parameter indicating scaling by parameter bounds 
    - `::ScaleNone`: Type parameter indicating no scaling should be applied


# Returns
Scaled parameters and their bounds according to default scaling factors
"""
scaleParameters

function scaleParameters(tbl_params, _sc::ScaleNone)
    default = copy(tbl_params.default)
    ub = copy(tbl_params.upper)  # upper bounds
    lb = copy(tbl_params.lower)   # lower bounds
    checkParameterBounds(tbl_params.name, default, lb, ub, _sc, show_info=true, model_names=tbl_params.model_approach)
    return (default, lb, ub)
end
    
function scaleParameters(tbl_params, _sc::ScaleDefault)
    default = abs.(copy(tbl_params.default))
    ub = copy(tbl_params.upper ./ default)   # upper bounds
    lb = copy(tbl_params.lower ./ default)   # lower bounds
    default = tbl_params.default ./ default
    checkParameterBounds(tbl_params.name, default, lb, ub, _sc, show_info=true, model_names=tbl_params.model_approach)
    return (default, lb, ub)
end

function scaleParameters(tbl_params, _sc::ScaleBounds)
    default = copy(tbl_params.default)
    ub = copy(tbl_params.upper)  # upper bounds
    lb = copy(tbl_params.lower)   # lower bounds
    default = (default - lb)  ./ (ub - lb)
    lb = zero(lb)
    ub = one.(ub)
    checkParameterBounds(tbl_params.name, default, lb, ub, _sc, show_info=true, model_names=tbl_params.model_approach)
    return (default, lb, ub)
end


"""
    updateModelParameters(tbl_params::Table, selected_models::Tuple, param_vector::AbstractArray)
    updateModelParameters(tbl_params::Table, selected_models::LongTuple, param_vector::AbstractArray)
    updateModelParameters(param_to_index::NamedTuple, selected_models::Tuple, param_vector::AbstractArray)
    updateModelParameters(selected_models::Tuple, param_vector::AbstractArray, ::Val{p_vals})

Updates the parameters of SINDBAD models based on the provided parameter vector without mutating the original table of parameters.

# Arguments:
- `tbl_params::Table`: A table of SINDBAD model parameters selected for optimization. Contains parameter names, bounds, and scaling information.
- `selected_models::Tuple`: A tuple of all models selected in the given model structure.
- `selected_models::LongTuple`: A long tuple of models, which is converted into a standard tuple for processing.
- `param_vector::AbstractArray`: A vector of parameter values to update the models.
- `param_to_index::NamedTuple`: A mapping of parameter indices to model names, used for updating specific parameters in the models.
- `::Val{p_vals}`: A generated function argument that allows compile-time parameter updates for specific models and parameters.

# Returns:
- A tuple of updated models with their parameters modified according to the provided `param_vector`.

# Notes:
- The function supports multiple input formats for `selected_models` (e.g., `LongTuple`, `NamedTuple`) and adapts accordingly.
- If `tbl_params` is provided, the function uses it to find and update the relevant parameters for each model.
- The `param_to_index` variant allows for a more direct mapping of parameters to models, bypassing the need for a parameter table.
- The generated function variant (`::Val{p_vals}`) is used for compile-time optimization of parameter updates.

# Examples:
1. **Using `tbl_params` and `selected_models`:**
```julia
updated_models = updateModelParameters(tbl_params, selected_models, param_vector)
```

2. **Using `param_to_index` for direct mapping:**
```julia
updated_models = updateModelParameters(param_to_index, selected_models, param_vector)
```

3. **Using a generated function for compile-time updates:**
```julia
updated_models = updateModelParameters(selected_models, param_vector, Val(p_vals))
```

# Implementation Details:
- The function iterates over the models in `selected_models` and updates their parameters based on the provided `param_vector`.
- For each model, it checks if the parameter belongs to the model's approach (using `tbl_params.model_approach`) and updates the corresponding value.
- The `param_to_index` variant uses a mapping to directly replace parameter values in the models.
- The generated (with @generated) function variant (`::Val{p_vals}`) creates a compile-time optimized update process for specific parameters and models.
"""
updateModelParameters

function updateModelParameters(tbl_params::Table, selected_models::LongTuple, param_vector::AbstractArray)
    selected_models = getTupleFromLongTuple(selected_models)
    return updateModelParameters(tbl_params, selected_models, param_vector)
end

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

"""
    updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)

Updates the parameters of selected models using the provided parameter vector.

# Arguments
- `param_vector`: Vector containing the new parameter values
- `param_updater`: Function or object that defines how parameters should be updated
- `parameter_scaling_type`: Specifies the type of scaling to be applied to parameters
- `selected_models`: Collection of models whose parameters need to be updated

# Returns
Updated models with new parameter values
"""
function updateModels(param_vector, param_updater, parameter_scaling_type, selected_models)
    param_vector = backScaleParameters(param_vector, param_updater, parameter_scaling_type)
    updated_models = updateModelParameters(param_updater, selected_models, param_vector)
    return updated_models
end