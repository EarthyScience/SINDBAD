export booleanizeArray
export doNothing
export getAbsDataPath
export getBool
export isInvalid
export nonUnique
export replaceInvalid
export setLogLevel
export toggleStackTraceNT
export valToSymbol

"""
    booleanizeArray(_array)

DOCSTRING
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

DOCSTRING
"""
function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        data_path = joinpath(info.experiment_root, data_path)
    end
    return data_path
end


"""
    getBool(var::Bool)

DOCSTRING
"""
function getBool(var::Bool)
    return var
end

"""
    getBool(var)

DOCSTRING
"""
function getBool(var)
    return valToSymbol(var)
end


"""
    isInvalid(num)

DOCSTRING
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

DOCSTRING
"""
function replaceInvalid(_data, _data_fill)
    _data = isInvalid(_data) ? _data_fill : _data
    return _data
end


"""
    setLogLevel()

DOCSTRING
"""
function setLogLevel()
    logger = ConsoleLogger(stderr, Logging.Info)
    global_logger(logger)
end

"""
    setLogLevel(log_level)

DOCSTRING
"""
function setLogLevel(log_level)
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
    toggleStackTraceNT()

Modifies Base.show to reduce the size of error stacktrace of sindbad
"""
function toggleStackTraceNT(toggle=true)
    if toggle
        eval(:(Base.show(io::IO, nt::Type{<:NamedTuple}) = print(io, "NT")))
        eval(:(Base.show(io::IO, nt::Type{<:Tuple}) = print(io, "T")))
        show = eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = print(io, "NT")))
    else
        show = Base.show
    end
    return show
end


"""
    valToSymbol(val)

returns the symbol from which val was created for a type dispatch based on name
"""
function valToSymbol(val)
    return typeof(val).parameters[1]
end
