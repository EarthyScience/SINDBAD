export convertRunFlagsToTypes
export createArrayofType
export getNumberType
export getTypeInstanceForCostMetric
export getTypeInstanceForFlags
export getTypeInstanceForNamedOptions

"""
    convertRunFlagsToTypes(info)

converts the model running related flags to types for dispatch
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
    createArrayofType(input_values, pool_array, num_type, indx, ismain, array_type::SindbadModelArrayType)

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
createArrayofType

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
    getNumberType(t::String)

A helper function to get the number type from the specified string
"""
function getNumberType(t::String)
    ttype = eval(Meta.parse(t))
    return ttype
end

"""
    getNumberType(t::DataType)

A helper function to get the number type from the specified type
"""
function getNumberType(t::DataType)
    return t
end



"""
    getTypeInstanceForCostMetric(mode_name)

a helper function to get the type for spinup mode
"""
function getTypeInstanceForCostMetric(option_name::String)
    opt_ss = toUpperCaseFirst(option_name)
    struct_instance = getfield(SindbadMetrics, opt_ss)()
    return struct_instance
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

