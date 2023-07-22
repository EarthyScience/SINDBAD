export getDataDims, getNumberOfTimeSteps, getAbsDataPath
export AllNaN
export getForcingTimeSize
export getForcingForTimeStep
export filterVariables
export getKeyedArrayFromYaxArray
export getNamedDimsArrayFromYaxArray
export getDimArrayFromYaxArray
export getObsKeyedArrayFromYaxArray
export mapCleanData
export booleanize_mask


function booleanize_mask(yax_mask)
    dfill = 0.0
    yax_mask = map(yax_point -> cleanInvalid(yax_point, dfill), yax_mask)
    yax_mask_bits = all.(>(dfill), yax_mask)
    return yax_mask_bits
end


"""
    AllNaN <: YAXArrays.DAT.ProcFilter

Add skipping filter for pixels with all nans in YAXArrays
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)


"""
    applyQCBound(data_in, data_qc, bounds_qc, dfill)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""
function applyQCBound(data_in, data_qc, bounds_qc, dfill)
    data_out = data_in
    if data_qc < first(bounds_qc) || data_qc > last(bounds_qc)
        data_out = dfill
    end
    return data_out
end

"""
    applyUnitConversion(data_in, conversion, isadditive=false)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""
function applyUnitConversion(data_in, conversion, isadditive=false)
    if isadditive
        data_out = data_in + conversion
    else
        data_out = data_in * conversion
    end
    return data_out
end

function mapCleanData(yax, yax_qc, dfill, bounds_qc, vinfo, ::Val{T}) where {T}
    yax = map(yax_point -> cleanData(yax_point, dfill, vinfo, Val(T)), yax)
    if !isnothing(bounds_qc) && !isnothing(yax_qc)
        yax = map((da, dq) -> applyQCBound(da, dq, bounds_qc, dfill), yax, yax_qc)
    end
    return yax
end

function cleanInvalid(yax_point, dfill)
    yax_point = ismissing(yax_point) ? dfill : yax_point
    yax_point = isnan(yax_point) ? dfill : yax_point
    yax_point = isinf(yax_point) ? dfill : yax_point
    return yax_point
end

function cleanData(yax_point, dfill, vinfo, ::Val{T}) where {T}
    yax_point = cleanInvalid(yax_point, dfill)
    yax_point = applyUnitConversion(yax_point, vinfo.source_to_sindbad_unit,
    vinfo.additive_unit_conversion)
    bounds = vinfo.bounds
    if !isnothing(bounds)
        yax_point = clamp(yax_point, first(bounds), last(bounds))
    end
    return T(yax_point)
end

# function mapCleanData(yax, dfill, vinfo, ::Val{T}) where {T}
#     yax = map(x -> ismissing(x) ? dfill : x, yax)
#     yax = map(x -> isnan(x) ? dfill : x, yax)
#     yax = map(x -> applyUnitConversion(x, vinfo.source_to_sindbad_unit,
#     vinfo.additive_unit_conversion), yax)
#     bounds = vinfo.bounds
#     if !isnothing(bounds)
#         yax = map(x -> clamp(x, first(bounds), last(bounds)), yax)
#     end
#     return T.(yax)
# end


function getAbsDataPath(info, data_path)
    if !isabspath(data_path)
        data_path = joinpath(info.experiment_root, data_path)
    end
    return data_path
end

function getDataDims(c, mappinginfo)
    inax = [] # String[]
    axnames = DimensionalData.name(dims(c)) #YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    return InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    return length(getAxis(time_name, incubes[i1]).values)
end

function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v ∈ forcing
        if in(:time, AxisKeys.dimnames(v))
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

@generated function getForcingTimeSize(forcing, ::Val{forc_vars}) where {forc_vars}
    output = quote
        forcingTimeSize = 1
    end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
        push!(output.args,
            quote
                forcingTimeSize = in(:time, AxisKeys.dimnames(v)) ? size(v, 1) :
                                  forcingTimeSize
            end)
    end
    push!(output.args, quote
        forcingTimeSize
    end)
    return output
end

@generated function getForcingForTimeStep(forcing, ::Val{forc_vars}, ts, f_t) where {forc_vars}
    output = quote end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
        push!(output.args, quote
            d = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
        end)
        push!(output.args,
            Expr(:(=),
                :f_t,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
    end
    return output
end

function getForcingForTimeStep(forcing::NamedTuple, ts::Int64, forcing_t)
    for f ∈ keys(forcing)
        v = forcing[f]
        forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
    return forcing_t
end

function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

"""
filterVariables(out::NamedTuple, varsinfo; filter_variables=true)
"""
function filterVariables(out::NamedTuple, varsinfo::NamedTuple; filter_variables=true)
    if !filter_variables
        fout = out
    else
        fout = (;)
        for k ∈ keys(varsinfo)
            v = getfield(varsinfo, k)
            # fout = setTupleField(fout, (k, v, getfield(out, k)))
            fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
        end
    end
    return fout
end

"""
getNamedDimsArrayFromYaxArray(input::NamedTuple)
"""
function getNamedDimsArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        namesCube = YAXArrayBase.dimnames(c)
        NamedDimsArray(Array(c.data); Tuple(k => getproperty(c, k) for k ∈ namesCube)...)
    end
    return (; Pair.(ks, keyedData)...)
end

"""
getDimArrayFromYaxArray(input::NamedTuple)
"""
function getDimArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        YAXArrayBase.yaxconvert(DimArray, Array(c.data))
    end
    return (; Pair.(ks, keyedData)...)
end

"""
getKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getKeyedArrayFromYaxArray(input)
    ks = input.variables
    in_cubes = input.data
    keyedData = map(in_cubes) do c
        namesCube = DimensionalData.name(dims(c)) #YAXArrays.Axes.axname.(caxes(c))
        KeyedArray(Array(c.data); Tuple(k => DimensionalData.lookup(c, k) for k ∈ namesCube)...)
    end
    return (; Pair.(ks, keyedData)...)
end


"""
getObsKeyedArrayFromYaxArray(input::NamedTuple)
"""
function getObsKeyedArrayFromYaxArray(input)
    ks = input.variables
    keyedData = map(input.data) do c
        namesCube = DimensionalData.name(dims(c)) #YAXArrays.Axes.axname.(caxes(c))
        KeyedArray(Array(c.data); Tuple(k => DimensionalData.lookup(c, k) for k ∈ namesCube)...)
    end
    return keyedData
end
