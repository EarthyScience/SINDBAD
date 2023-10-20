export convertRunFlagsToTypes
export createArrayofType
export getNumberType
export getTypeInstanceForCostMetric
export getTypeInstanceForFlags
export getTypeInstanceForNamedOptions
export setNumberType

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

