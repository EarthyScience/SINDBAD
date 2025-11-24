export addPackage
export booleanizeArray
export doNothing
export entertainMe
export getAbsDataPath
export getSindbadDataDepot
export nonUnique
export replaceInvalid
export setLogLevel
export sindbadBanner
export tabularizeList
export toggleStackTraceNT
export toUpperCaseFirst
export valToSymbol

figlet_fonts = ("3D Diagonal", "3D-ASCII", "3d", "4max", "5 Line Oblique", "5x7", "6x9", "AMC AAA01", "AMC Razor", "AMC Razor2", "AMC Slash", "AMC Slider", "AMC Thin", "AMC Tubes", "AMC Untitled", "ANSI Regular", "ANSI Shadow", "Big Money-ne", "Big Money-nw", "Big Money-se", "Big Money-sw", "Bloody", "Caligraphy2", "DOS Rebel", "Dancing Font", "Def Leppard", "Delta Corps Priest 1", "Electronic", "Elite", "Fire Font-k", "Fun Face", "Georgia11", "Larry 3D", "Lil Devil", "Line Blocks", "NT Greek", "NV Script", "Red Phoenix", "Rowan Cap", "S Blood", "THIS", "Two Point", "USA Flag", "Wet Letter", "acrobatic", "alligator", "alligator2", "alligator3", "alphabet", "arrows", "asc_____", "avatar", "banner", "banner3", "banner3-D", "banner4", "barbwire", "bell", "big", "bolger", "braced", "bright", "bulbhead", "caligraphy", "charact2", "charset_", "clb6x10", "colossal", "computer", "cosmic", "crawford", "crazy", "diamond", "doom", "fender", "fraktur", "georgi16", "ghoulish", "graffiti", "hollywood", "jacky", "jazmine", "maxiwi", "merlin1", "nancyj", "nancyj-improved", "nscript", "o8", "ogre", "pebbles", "reverse", "roman", "rounded", "rozzo", "script", "slant", "small", "soft", "speed", "standard", "stop", "tanja", "thick", "train", "univers", "whimsy");

"""
    addPackage(where_to_add, the_package_to_add)

Adds a specified Julia package to the environment of a given module or project.

# Arguments:
- `where_to_add`: The module or project where the package should be added.
- `the_package_to_add`: The name of the package to add.

# Behavior:
- Activates the environment of the specified module or project.
- Checks if the package is already installed in the environment.
- If the package is not installed:
  - Adds the package to the environment.
  - Removes the `Manifest.toml` file and reinstantiates the environment to ensure consistency.
  - Provides instructions for importing the package in the module.
- Restores the original environment after the operation.

# Notes:
- This function assumes that the `where_to_add` module or project is structured with a standard Julia project layout.
- It requires the `Pkg` module for package management, which is re-exported from core Sindbad.

# Example:
```julia
addPackage(MyModule, "DataFrames")
```
"""
function addPackage(where_to_add, the_package_to_add)

    from_where = dirname(Base.active_project())
    dir_where_to_add = joinpath(dirname(pathof(where_to_add)), "../")
    cd(dir_where_to_add)
    Pkg.activate(dir_where_to_add)
    is_installed = any(dep.name == the_package_to_add for dep in values(Pkg.dependencies()))

    if is_installed
        @info "$the_package_to_add is already installed in $where_to_add. Nothing to do. Return to base environment at $from_where"
    else

        Pkg.add(the_package_to_add)
        rm("Manifest.toml")
        Pkg.instantiate()
        @info "Added $(the_package_to_add) to $(where_to_add). Add the following to the imports in $(pathof(where_to_add)) with\n\nusing $(the_package_to_add)\n\n. You may need to restart the REPL/environment at $(from_where)."
    end
    cd(from_where)
    Pkg.activate(from_where)
    Pkg.resolve()
end

"""
    booleanizeArray(_array)

Converts an array into a boolean array where elements greater than zero are `true`.

# Arguments:
- `_array`: The input array to be converted.

# Returns:
A boolean array with the same dimensions as `_array`.
"""
function booleanizeArray(_array)
    _data_fill = 0.0
    _array = map(_data -> replaceInvalid(_data, _data_fill), _array)
    _array_bits = all.(>(_data_fill), _array)
    return _array_bits
end

"""
    doNothing(dat)

Returns the input as is, without any modifications.

# Arguments:
- `dat`: The input data.

# Returns:
The same input data.
"""
function doNothing(_data)
    return _data
end

"""
    entertainMe(n=10, disp_text="SINDBAD")

Displays the given text `disp_text` as a banner `n` times.

# Arguments:
- `n`: Number of times to display the banner (default: 10).
- `disp_text`: The text to display (default: "SINDBAD").
- `c_olor`: Whether to display the text in random colors (default: `false`).
"""
function entertainMe(n=10, disp_text="SINDBAD"; c_olor=true)
    for _x in 1:n
        sindbadBanner(disp_text, c_olor)
        sleep(0.1)
    end
end

"""
    getAbsDataPath(info, data_path)

Converts a relative data path to an absolute path based on the experiment directory.

# Arguments:
- `info`: The SINDBAD experiment information object.
- `data_path`: The relative or absolute data path.

# Returns:
An absolute data path.
"""
function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        d_data_path = getSindbadDataDepot(local_data_depot=data_path)
        if data_path == d_data_path
            data_path = joinpath(info.experiment.dirs.experiment, data_path)
        else
            data_path = joinpath(d_data_path, data_path)
        end
    end
    return data_path
end


"""
    getSindbadDataDepot(; env_data_depot_var="SINDBAD_DATA_DEPOT", local_data_depot="../data")

Retrieve the Sindbad data depot path.

# Arguments
- `env_data_depot_var`: Environment variable name for the data depot (default: "SINDBAD\\_DATA\\_DEPOT")
- `local_data_depot`: Local path to the data depot (default: "../data")

# Returns
The path to the Sindbad data depot.
"""
function getSindbadDataDepot(; env_data_depot_var="SINDBAD_DATA_DEPOT", local_data_depot="../data")
    data_depot = isabspath(local_data_depot) ? local_data_depot : haskey(ENV, env_data_depot_var) ? ENV[env_data_depot_var] : local_data_depot
    return data_depot
end


"""
    nonUnique(x::AbstractArray{T}) where T

Finds and returns a vector of duplicate elements in the input array.

# Arguments:
- `x`: The input array.

# Returns:
A vector of duplicate elements.
"""
function nonUnique(x::AbstractArray{T}) where {T}
    xs = sort(x)
    duplicatedvector = T[]
    for i ∈ eachindex(xs)[2:end]
        if (
            isequal(xs[i], xs[i-1]) &&
            (length(duplicatedvector) == 0 || !isequal(duplicatedvector[end], xs[i]))
        )
            push!(duplicatedvector, xs[i])
        end
    end
    return duplicatedvector
end

"""
    replaceInvalid(_data, _data_fill)

Replaces invalid numbers in the input with a specified fill value.

# Arguments:
- `_data`: The input number.
- `_data_fill`: The value to replace invalid numbers with.

# Returns:
The input number if valid, otherwise the fill value.
"""
function replaceInvalid(_data, _data_fill)
    _data = isInvalid(_data) ? _data_fill : _data
    return _data
end

"""
    setLogLevel()

Sets the logging level to `Info`.
"""
function setLogLevel()
    logger = ConsoleLogger(stderr, Logging.Info)
    global_logger(logger)
end

"""
    setLogLevel(log_level::Symbol)

Sets the logging level to the specified level.

# Arguments:
- `log_level`: The desired logging level (`:debug`, `:warn`, `:error`).
"""
function setLogLevel(log_level::Symbol)
    logger = ConsoleLogger(stderr, Logging.Info)
    if log_level == :debug
        logger = ConsoleLogger(stderr, Logging.Debug)
    elseif log_level == :warn
        logger = ConsoleLogger(stderr, Logging.Warn)
    elseif log_level == :error
        logger = ConsoleLogger(stderr, Logging.Error)
    end
    global_logger(logger)
end

"""
    sindbadBanner(disp_text="SINDBAD")

Displays the given text as a banner using Figlets.

# Arguments:
- `disp_text`: The text to display (default: "SINDBAD").
- `c_olor`: Whether to display the text in random colors (default: `false`).
"""
function sindbadBanner(disp_text="SINDBAD", c_olor=true)
    if c_olor
        print(Utils.Crayon(; foreground=rand(0:255)), "\n")
    end
    println("######################################################################################################\n")
    FIGlet.render(disp_text, rand(figlet_fonts))
    println("######################################################################################################")
    return nothing
end

"""
    tabularizeList(_list)

Converts a list or tuple into a table using `TypedTables`.

# Arguments:
- `_list`: The input list or tuple.

# Returns:
A table representation of the input list.
"""
function tabularizeList(_list)
    table = Table((; name=[_list...]))
    return table
end

"""
    toggleStackTraceNT(toggle=true)

Modifies the display of stack traces to reduce verbosity for NamedTuples.

# Arguments:
- `toggle`: Whether to enable or disable the modification (default: `true`).
"""
function toggleStackTraceNT(toggle=true)
    if toggle
        eval(:(Base.show(io::IO, nt::Type{<:NamedTuple}) = print(io, "NT")))
        eval(:(Base.show(io::IO, nt::Type{<:Tuple}) = print(io, "T")))
        eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = print(io, "NT")))
    else
        # TODO: Restore the default behavior (currently not implemented).
        eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = Base.show(io::IO, nt::Type{<:NTuple})))
    end
    return nothing
end

"""
    toUpperCaseFirst(s::String, prefix="")

Converts the first letter of each word in a string to uppercase, removes underscores, and adds a prefix.

# Arguments:
- `s`: The input string.
- `prefix`: A prefix to add to the resulting string (default: "").

# Returns:
A `Symbol` with the transformed string.
"""
function toUpperCaseFirst(s::String, prefix="")
    return Symbol(prefix * join(uppercasefirst.(split(s,"_"))))
end

"""
    valToSymbol(val)

Returns the symbol corresponding to the type of the input value.

# Arguments:
- `val`: The input value.

# Returns:
A `Symbol` representing the type of the input value.
"""
function valToSymbol(val)
    return typeof(val).parameters[1]
end