export getSindbadDefinitions
export methodsOf
export showMethodsOf
export loopWriteTypeDocString
export writeTypeDocString
export getTypeDocString

"""
    getSindbadDefinitions(sindbad_module, what_to_get; internal_only=true)

Returns all defined (and optionally internal) objects in the SINDBAD framework.

# Arguments
- `sindbad_module`: The module to search for defined things
- `what_to_get`: The type of things to get (e.g., Type, Function)
- `internal_only`: Whether to only include internal definitions (default: true)

# Returns
- An array of all defined things in the SINDBAD framework

# Example
```julia
# Get all defined types in the SINDBAD framework
defined_types = getSindbadDefinitions(Sindbad, Type)
```
"""
function getSindbadDefinitions(sindbad_module, what_to_get; internal_only=true)
    all_defined_things = filter(x -> isdefined(sindbad_module, x) && isa(getproperty(sindbad_module, x), what_to_get), names(sindbad_module))
    defined_things = all_defined_things
    if internal_only
        defined_things = []
        for d_thing in all_defined_things
            d = getproperty(sindbad_module, d_thing)
            d_parent = parentmodule(d)
            if nameof(d_parent) == nameof(sindbad_module)
                push!(defined_things, d)
            end
        end    
    end
    return defined_things
end


"""
    getTypeDocString(T::Type)

Generate a docstring for a type in a formatted way.

# Description
This function generates a formatted docstring for a type, including its purpose and type hierarchy.

# Arguments
- `T`: The type for which the docstring is to be generated 

# Returns
- A string containing the formatted docstring for the type.

"""
function getTypeDocString(T::Type)
    doc_string = ""
    doc_string *= "\n# $(nameof(T))\n\n"
    doc_string *= "$(purpose(T))\n\n"
    doc_string *= "## Type Hierarchy\n\n"
    doc_string *= "```$(join(nameof.(supertypes(T)), " <: "))```\n\n"
    sub_types = subtypes(T)
    if length(sub_types) > 0
        doc_string *= "-----\n\n"
        doc_string *= "# Extended help\n\n"
        doc_string *= "## Available methods/subtypes:\n"
        doc_string *= "$(methodsOf(T, is_subtype=true))\n\n"
    end
    return doc_string
end


"""
    methodsOf(T::Type; ds="", is_subtype=false, bullet=" - ")
    methodsOf(M::Module; the_type=Type, internal_only=true)

Display subtypes and their purposes for a type or module in a formatted way.

# Description
This function provides a hierarchical display of subtypes and their purposes for a given type or module. For types, it shows a tree-like structure of subtypes and their purposes. For modules, it shows all defined types and their subtypes.

# Arguments
- `T::Type`: The type whose subtypes should be displayed
- `M::Module`: The module whose types should be displayed
- `ds::String`: Delimiter string between entries (default: newline)
- `is_subtype::Bool`: Whether to include nested subtypes (default: false)
- `bullet::String`: Bullet point for each entry (default: " - ")
- `the_type::Type`: Type of objects to display in module (default: Type)
- `internal_only::Bool`: Whether to only show internal definitions (default: true)

# Returns
- A formatted string showing the hierarchy of subtypes and their purposes

# Examples
```julia
# Display subtypes of a type
methodsOf(LandEcosystem)

# Display with custom formatting
methodsOf(LandEcosystem; ds=", ", bullet=" * ")

# Display including nested subtypes
methodsOf(LandEcosystem; is_subtype=true)

# Display types in a module
methodsOf(Sindbad)

# Display specific types in a module
methodsOf(Sindbad; the_type=Function)
```

# Extended help
The output format for types is:
```
## TypeName
Purpose of the type

## Available methods/subtypes:
 - subtype1: purpose
 - subtype2: purpose
    - nested_subtype1: purpose
    - nested_subtype2: purpose
```

If no subtypes exist, it will show " - `None`".
"""
function methodsOf end

function methodsOf(T::Type; ds="\n", is_subtype=false, bullet=" - ")
    sub_types = subtypes(T)
    type_name = nameof(T)
    if !is_subtype
        ds *= "## $type_name\n$(purpose(T))\n\n"
        ds *= "## Available methods/subtypes:\n"
    end

    if isempty(sub_types) && !is_subtype
        ds *= " - `None`\n"
    else
        for sub_type in sub_types
            sub_type_name = nameof(sub_type)
            ds *= "$bullet `$(sub_type_name)`: $(purpose(sub_type)) \n"
            sub_sub_types = subtypes(sub_type)
            if !isempty(sub_sub_types)
                ds = methodsOf(sub_type; ds=ds, is_subtype=true, bullet="    " * bullet)
            end
        end
    end
    return ds
end

function methodsOf(M::Module; the_type=Type,internal_only=true)
    defined_types = getSindbadDefinitions(M, the_type, internal_only=internal_only)
    ds = "\n"
    foreach(defined_types) do defined_type
        M_type = getproperty(M, nameof(defined_type))
        M_subtypes = subtypes(M_type)
        is_subtype = isempty(M_subtypes)
        ds = is_subtype ? ds : ds * "\n"
        ds = methodsOf(M_type; ds=ds, is_subtype=is_subtype, bullet=" - ")
    end
    return ds
end



"""
    showMethodsOf(T)

Display the subtypes and their purposes of a type in a formatted way.

# Description
This function displays the hierarchical structure of subtypes and their purposes for a given type. It uses `methodsOf` internally to generate the formatted output and prints it to the console.

# Arguments
- `T`: The type whose subtypes and purposes should be displayed

# Returns
- `nothing`

# Examples
```julia
# Display subtypes of LandEcosystem
showMethodsOf(LandEcosystem)

# Display subtypes of a specific model type
showMethodsOf(ambientCO2)
```

# Extended help
The output format is the same as `methodsOf`, showing:
```
## TypeName
Purpose of the type

## Available methods/subtypes:
 - subtype1: purpose
 - subtype2: purpose
    - nested_subtype1: purpose
    - nested_subtype2: purpose
```

This function is a convenience wrapper around `methodsOf` that automatically prints the output to the console.
"""
function showMethodsOf(T)
    println(methodsOf(T))
    return nothing
end

"""
    writeTypeDocString(o_file, T)

Write a docstring for a type to a file.

# Description
This function writes a docstring for a type to a file.

# Arguments
- `o_file`: The file to write the docstring to
- `T`: The type for which the docstring is to be generated

# Returns
- `o_file`: The file with the docstring written to it

"""
function writeTypeDocString(o_file, T)
    doc_string = Base.Docs.doc(T)
    if startswith(string(doc_string), "No documentation found for public symbol")
       write(o_file, "@doc \"\"\"\n$(getTypeDocString(T))\n\"\"\"\n")
       # write(o_file, "$(nameof(T))\n\n")
       write(o_file, "$(T)\n\n")
    end
    return o_file
 end

"""
    loopWriteTypeDocString(o_file, T)

Write a docstring for a type to a file.

# Description
This function writes a docstring for a type to a file.

# Arguments
- `o_file`: The file to write the docstring to
- `T`: The type for which the docstring is to be generated

# Returns
- `o_file`: The file with the docstring written to it

"""
 function loopWriteTypeDocString(o_file, T)
    writeTypeDocString(o_file, T)
    sub_types = subtypes(T)
    for sub_type in sub_types
       o_file = loopWriteTypeDocString(o_file, sub_type)
    end
    return o_file
 end
