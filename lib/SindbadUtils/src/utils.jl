export booleanizeArray
export doNothing
export entertainMe
export getAbsDataPath
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

Wrap the nested fields of namedtuple output of sindbad land into a nested structure of views that can be easily accessed with a dot notation
"""
struct LandWrapper{S}
    s::S
end
struct GroupView{S}
    groupname::Symbol
    s::S
end
struct ArrayView{T,N,S<:AbstractArray{<:Any,N}} <: AbstractArray{T,N}
    s::S
    groupname::Symbol
    arrayname::Symbol
end
Base.getproperty(s::LandWrapper, aggr_func::Symbol) = GroupView(aggr_func, getfield(s, :s))
"""
    Base.getproperty(g::GroupView, aggr_func::Symbol)


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


"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)
Base.size(g::GroupView) = size(getfield(g, :s))
Base.length(g::GroupView) = prod(size(g))

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


"""
function booleanizeArray(_array)
    _data_fill = 0.0
    _array = map(_data -> replaceInvalid(_data, _data_fill), _array)
    _array_bits = all.(>(_data_fill), _array)
    return _array_bits
end


"""
    doNothing(dat)

return the input as is
"""
function doNothing(_data)
    return _data
end

"""
    entertainMe(n=10, disp_text="SINDBAD")

display the disp_text n times
"""
function entertainMe(n=10, disp_text="SINDBAD", c_olor=false)
    for _x in 1:n
        sindbadBanner(disp_text, c_olor)
        sleep(0.1)
    end
end

"""
    getAbsDataPath(info, data_path)


"""
function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        data_path = joinpath(info.experiment.dirs.experiment, data_path)
    end
    return data_path
end


"""
    isInvalid(_data::Number)

returns if the input number is invalid
"""
function isInvalid(_data)
    return isnothing(_data) || ismissing(_data) || isnan(_data) || isinf(_data)
end


"""
    nonUnique(x::AbstractArray{T}) where T

returns a vector of duplicates in the input vector
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

replace invalid number with a replace/fill value
"""
function replaceInvalid(_data, _data_fill)
    _data = isInvalid(_data) ? _data_fill : _data
    return _data
end


"""
    setLogLevel()

change the display level to Info
"""
function setLogLevel()
    logger = ConsoleLogger(stderr, Logging.Info)
    global_logger(logger)
end

"""
    setLogLevel(log_level::Symbol)

change the display level to specifed level input level
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

displays display text as a banner using Figlets
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

convert a list/tuple to a Table from TypedTables
"""
function tabularizeList(_list)
    table = Table((; name=[_list...]))
    return table
end

"""
    toggleStackTraceNT()

Modifies Base.show to reduce the size of error stacktrace of sindbad
"""
function toggleStackTraceNT(toggle=true)
    if toggle
        eval(:(Base.show(io::IO, nt::Type{<:NamedTuple}) = print(io, "NT")))
        eval(:(Base.show(io::IO, nt::Type{<:Tuple}) = print(io, "T")))
        eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = print(io, "NT")))
    else
        #TODO this does not seem to restore the base show to default
        eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = Base.show(io::IO, nt::Type{<:NTuple})))
    end
    return nothing
end


"""
    toUpperCaseFirst(s::String, prefix=")

returns the uppercase first Symbol from input string with _ removed and prefix at the beginning
"""
function toUpperCaseFirst(s::String, prefix="")
    return Symbol(prefix * join(uppercasefirst.(split(s,"_"))))
end


"""
    valToSymbol(val)

returns the symbol from which val was created for a type dispatch based on name
"""
function valToSymbol(val)
    return typeof(val).parameters[1]
end