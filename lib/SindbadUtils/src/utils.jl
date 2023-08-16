export booleanizeArray
export doNothing
export getAbsDataPath
export isInvalid
export landWrapper
export nonUnique
export replaceInvalid
export setLogLevel
export tabularizeList
export toggleStackTraceNT
export toUpperCaseFirst
export valToSymbol

"""
    landWrapper{S}

Wrap the nested fields of namedtuple output of sindbad land into a nested structure of views that can be easily accessed with a dot notation
"""
struct landWrapper{S}
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
Base.getproperty(s::landWrapper, aggr_func::Symbol) = GroupView(aggr_func, getfield(s, :s))
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
Base.propertynames(o::landWrapper) = propertynames(first(getfield(o, :s)))
Base.keys(o::landWrapper) = propertynames(o)
Base.getindex(o::landWrapper, s::Symbol) = getproperty(o, s)

"""
    Base.propertynames(o::GroupView)


"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)



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
    getAbsDataPath(info, data_path)


"""
function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        data_path = joinpath(info.experiment_root, data_path)
    end
    return data_path
end


"""
    isInvalid(num)


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

