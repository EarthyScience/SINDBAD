export convertRunFlagsToTypes
export createArrayofType
export getNumberType
export getTypeInstanceForCostMetric
export getTypeInstanceForFlags
export getTypeInstanceForNamedOptions

"""
    convertRunFlagsToTypes(info)

Converts model run-related flags from the experiment configuration into types for dispatch.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration, including model run flags.

# Returns:
- A NamedTuple `new_run` where each flag is converted into a corresponding type instance.

# Notes:
- Flags are processed recursively:
  - If a flag is a `NamedTuple`, its subfields are converted into types.
  - If a flag is a scalar, it is directly converted into a type using `getTypeInstanceForFlags`.
- The resulting `new_run` NamedTuple is used for type-based dispatch in SINDBAD's model execution.
"""
function convertRunFlagsToTypes(info)
    new_run = (;)
    dr = deepcopy(info.settings.experiment.flags)
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
    createArrayofType(input_values, pool_array, num_type, indx, ismain, array_type::ModelArrayType)

Creates an array or view of the specified type `array_type` based on the input values and configuration.

# Arguments:
- `input_values`: The input data to be converted or used for creating the array.
- `pool_array`: A preallocated array from which a view may be created.
- `num_type`: The numerical type to which the input values should be converted (e.g., `Float64`, `Int`).
- `indx`: A tuple of indices used to create a view from the `pool_array`.
- `ismain`: A boolean flag indicating whether the main array should be created (`true`) or a view should be created (`false`).
- `array_type`: A type dispatch that determines the array type to be created:
    - `ModelArrayView`: Creates a view of the `pool_array` based on the indices `indx`.
    - `ModelArrayArray`: Creates a new array by converting `input_values` to the specified `num_type`.
    - `ModelArrayStaticArray`: Creates a static array (`SVector`) from the `input_values`.

# Returns:
- An array or view of the specified type, created based on the input configuration.

# Notes:
- When `ismain` is `true`, the function converts `input_values` to the specified `num_type`.
- When `ismain` is `false`, the function creates a view of the `pool_array` using the indices `indx`.
- For `ModelArrayStaticArray`, the function ensures that the resulting static array (`SVector`) has the correct type and length.

# Examples:
1. **Creating a view from a preallocated array**:
```julia
pool_array = rand(10, 10)
indx = (1:5,)
view_array = createArrayofType(nothing, pool_array, Float64, indx, false, ModelArrayView())
```

2. **Creating a new array with a specific numerical type**:
```julia
input_values = [1.0, 2.0, 3.0]
new_array = createArrayofType(input_values, nothing, Float64, nothing, true, ModelArrayArray())
```

3. **Creating a static array (`SVector`)**:
```julia
input_values = [1.0, 2.0, 3.0]
static_array = createArrayofType(input_values, nothing, Float64, nothing, true, ModelArrayStaticArray())
```
"""
function createArrayofType end

function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayView)
    if ismain
        num_type.(input_values)
    else
        @view pool_array[[indx...]]
    end
end

function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayArray)
    return num_type.(input_values)
end

function createArrayofType(input_values, pool_array, num_type, indx, ismain, ::ModelArrayStaticArray)
    input_typed = typeof(num_type(1.0)) === eltype(input_values) ? input_values : num_type.(input_values) 
    return SVector{length(input_values)}(input_typed)
    # return SVector{length(input_values)}(num_type(ix) for ix ∈ input_values)
end

"""
    getNumberType(t)

Retrieves the numerical type based on the input, which can be a string or a data type.

# Arguments:
- `t`: The input specifying the numerical type. Can be:
  - A `String` representing the type (e.g., `"Float64"`, `"Int"`).
  - A `DataType` directly specifying the type (e.g., `Float64`, `Int`).

# Returns:
- The corresponding numerical type as a `DataType`.

# Notes:
- If the input is a string, it is parsed and evaluated to return the corresponding type.
- If the input is already a `DataType`, it is returned as-is.
"""
function getNumberType end

function getNumberType(t::String)
    ttype = eval(Meta.parse(t))
    return ttype
end

function getNumberType(t::DataType)
    return t
end


"""
    getTypeInstanceForCostMetric(mode_name::String)

Retrieves the type instance for a given cost metric based on its name.

# Arguments:
- `mode_name::String`: The name of the cost metric (e.g., `"RMSE"`, `"MAE"`).

# Returns:
- An instance of the corresponding cost metric type.

# Notes:
- The function converts the cost metric name to a type by capitalizing the first letter of each word and removing underscores.
- The type is retrieved from the `SindbadMetrics` module and instantiated.
- Used for dispatching cost metric calculations in SINDBAD.
"""
function getTypeInstanceForCostMetric(option_name::String)
    opt_ss = toUpperCaseFirst(option_name)
    struct_instance = getfield(Sindbad, opt_ss)()
    return struct_instance
end


"""
    getTypeInstanceForFlags(option_name::Symbol, option_value, opt_pref="Do")

Generates a type instance for boolean flags based on the flag name and value.

# Arguments:
- `option_name::Symbol`: The name of the flag (e.g., `:run_optimization`, `:save_info`).
- `option_value`: A boolean value (`true` or `false`) indicating the state of the flag.
- `opt_pref::String`: (Optional) A prefix for the type name. Defaults to `"Do"`.

# Returns:
- An instance of the corresponding type:
  - If `option_value` is `true`, the type name is prefixed with `opt_pref` (e.g., `DoRunOptimization`).
  - If `option_value` is `false`, the type name is prefixed with `opt_pref * "Not"` (e.g., `DoNotRunOptimization`).

# Notes:
- The function converts the flag name to a string, capitalizes the first letter of each word, and appends the appropriate prefix (`Do` or `DoNot`).
- The resulting type is retrieved from the `SindbadSetup` module and instantiated.
- This is used for type-based dispatch in SINDBAD's model execution.
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
    getTypeInstanceForNamedOptions(option_name)

Retrieves a type instance for a named option based on its string or symbol representation. These options are mainly within the optimization and temporal aggregation.

# Arguments:
- `option_name`: The name of the option, provided as either a `String` or a `Symbol`.

# Returns:
- An instance of the corresponding type from the `SindbadSetup` module.

# Notes:
- If the input is a `Symbol`, it is converted to a `String` before processing.
- The function capitalizes the first letter of each word in the option name and removes underscores to match the type naming convention.
- This is used for type-based dispatch in SINDBAD's configuration and execution.
- The type for temporal aggregation is set using `getTimeAggregatorTypeInstance` in `SindbadUtils`. It uses a similar approach and prefixes `Time` to type.

# Example:
- A named option for 
    - "cost_metric": "NSE_inv" would be converted to NSEInv type
    - "temporal_data_aggr": "month_anomaly" would be converted to MonthAnomaly

"""
function getTypeInstanceForNamedOptions end

function getTypeInstanceForNamedOptions(option_name::String)
    opt_ss = toUpperCaseFirst(option_name)
    struct_instance = getfield(SindbadSetup, opt_ss)()
    return struct_instance
end

function getTypeInstanceForNamedOptions(option_name::Symbol)
    getTypeInstanceForNamedOptions(string(option_name))
    return struct_instance
end

