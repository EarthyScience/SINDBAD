export booleanizeArray
export doNothing
export entertainMe
export getAbsDataPath
export getSindbadDataDepot
export isInvalid
export LandWrapper
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
    LandWrapper{S}

# Fields:
- `s::S`: The underlying NamedTuple or data structure being wrapped.
"""
struct LandWrapper{S}
    s::S
end

purpose(::Type{LandWrapper}) = "Wraps the nested fields of a NamedTuple output of SINDBAD land into a nested structure of views that can be easily accessed with dot notation."

"""
    GroupView{S}

# Fields:
- `groupname::Symbol`: The name of the group being accessed.
- `s::S`: The underlying data structure containing the group.
"""
struct GroupView{S}
    groupname::Symbol
    s::S
end

purpose(::Type{GroupView}) = "Represents a group of data within a `LandWrapper`, allowing access to specific groups of variables."

"""
    ArrayView{T,N,S<:AbstractArray{<:Any,N}}

# Fields:
- `s::S`: The underlying array being viewed.
- `groupname::Symbol`: The name of the group containing the array.
- `arrayname::Symbol`: The name of the array being accessed.
"""
struct ArrayView{T,N,S<:AbstractArray{<:Any,N}} <: AbstractArray{T,N}
    s::S
    groupname::Symbol
    arrayname::Symbol
end

purpose(::Type{ArrayView}) = "A view into a specific array within a group of data, enabling efficient access and manipulation."

Base.getproperty(s::LandWrapper, aggr_func::Symbol) = GroupView(aggr_func, getfield(s, :s))

# Define the setindex! method
function Base.setindex!(obj::LandWrapper{Vector{Any}}, value::LandWrapper, index::Int)
    obj.data[index] = value
end

# Define the setindex method
function Base.setindex(obj::LandWrapper{Vector{Any}}, value::LandWrapper, index::Int)
    obj.data[index] = value
end

# Define the getindex method
function Base.getindex(obj::LandWrapper{Vector{Any}}, value::LandWrapper, index::Int)
    return obj.data[index]
end

"""
    Base.getproperty(g::GroupView, aggr_func::Symbol)

Accesses a specific array within a group of data in a `GroupView`.

# Returns:
An `ArrayView` object for the specified array.
"""
function Base.getproperty(g::GroupView, aggr_func::Symbol)
    allarrays = getfield(g, :s)
    groupname = getfield(g, :groupname)
    T = typeof(first(allarrays)[groupname][aggr_func])
    return ArrayView{T,ndims(allarrays),typeof(allarrays)}(allarrays, groupname, aggr_func)
end

Base.size(a::ArrayView) = size(a.s)
Base.IndexStyle(a::Type{<:ArrayView}) = IndexLinear()
Base.getindex(a::ArrayView, i::Int) = a.s[i][a.groupname][a.arrayname]
Base.propertynames(o::LandWrapper) = propertynames(first(getfield(o, :s)))
Base.keys(o::LandWrapper) = propertynames(o)
Base.getindex(o::LandWrapper, s::Symbol) = getproperty(o, s)

"""
    Base.propertynames(o::GroupView)

Returns the property names of a group in a `GroupView`.
"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end

Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)
Base.size(g::GroupView) = size(getfield(g, :s))
Base.length(g::GroupView) = prod(size(g))

"""
    Base.show(io::IO, gv::GroupView)

Displays a summary of the contents of a `GroupView`.
"""
function Base.show(io::IO, gv::GroupView)
    print(io, "GroupView with")
    printstyled(io, ":"; color=:red)
    println(io)
    print(io, "  Vector Arrays of size $(size(getfield(gv, :s)))")
    printstyled(io, ":"; color=:blue)
    println(io)
    g_name = getfield(gv, :groupname)
    for name in propertynames(gv)
        g_data = getproperty(getproperty(first(getfield(gv, :s)), g_name), name)
        printstyled(io, "     $name"; color=6)
        printstyled(io, ": "; color=:yellow)
        if isa(g_data, Tuple)
            printstyled(io, "Tuple of length $(length(g_data))\n"; color=:light_black)
        elseif isa(g_data, AbstractArray)
            printstyled(io, "Vector Arrays of size $(size(g_data))\n"; color=:light_black)
        else
            printstyled(io, "$(typeof(g_data))\n"; color=:light_black)
        end
    end
end

function Base.show(io::IO, ::MIME"text/plain", lw::LandWrapper)
    print(io, "LandWrapper")
    printstyled(io, ":"; color=:red)
    println(io)
    for (i, groupname) in enumerate(propertynames(lw))
        if groupname in (:fluxes, :states, :diagnostics, :properties, :models, :pools, :constants)
            printstyled(io, "  $(groupname)"; color=12)
            printstyled(io, " ➘")
        else
            printstyled(io, "  $(groupname)"; color=:light_black)
            printstyled(io, ":"; color=:blue)
            group_data = first(getfield(lw, :s))[groupname]
            if length(propertynames(group_data))>1
                printstyled(io, " ➘")
            end
        end
        if i>20
            printstyled(io, "\n    ⋮ ")
            return
        end
        println(io)
    end
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
    data_depot = haskey(ENV, env_data_depot_var) ? ENV[env_data_depot_var] : local_data_depot
    return data_depot
end


"""
    isInvalid(_data::Number)

Checks if a number is invalid (e.g., `nothing`, `missing`, `NaN`, or `Inf`).

# Arguments:
- `_data`: The input number.

# Returns:
`true` if the number is invalid, otherwise `false`.
"""
function isInvalid(_data)
    return isnothing(_data) || ismissing(_data) || isnan(_data) || isinf(_data)
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
function sindbadBanner(disp_text="SINDBAD", c_olor=false)
    if c_olor
        print(SindbadUtils.Crayon(; foreground=rand(0:255)), "\n")
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