export AllNaN
export booleanizeMask
export cleanData
export filterVariables
export getArray
export getAbsDataPath
export getCombinedVariableInfo
export getDataDims
export getForcingTimeSize
export getForcingForTimeStep
export getKeyedArray
export getKeyedArrayWithNames
export getNamedDimsArrayWithNames
export getNumberOfTimeSteps
export getSpatialSubset
export getSindbadDims
export isInvalid
export landWrapper
export mapCleanData
export temporalAggregation


"""
    AllNaN <: YAXArrays.DAT.ProcFilter

Add skipping filter for pixels with all nans in YAXArrays
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)

"""
    booleanizeMask(yax_mask)

DOCSTRING
"""
function booleanizeMask(yax_mask)
    dfill = 0.0
    yax_mask = map(yax_point -> cleanInvalid(yax_point, dfill), yax_mask)
    yax_mask_bits = all.(>(dfill), yax_mask)
    return yax_mask_bits
end

"""
    spatialSubset(v, ss_range, nothing::Val{:site})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:site})
    return v[site=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:lat})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:lat})
    return v[lat=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:latitude})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:latitude})
    return v[latitude=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:lon})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:lon})
    return v[lon=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:longitude})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:longitude})
    return v[longitude=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:id})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:id})
    return v[id=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:Id})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:Id})
    return v[Id=ss_range]
end

"""
    spatialSubset(v, ss_range, nothing::Val{:ID})

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:ID})
    return v[ID=ss_range]
end

"""
    getSpatialSubset(ss, v)

DOCSTRING
"""
function getSpatialSubset(ss, v)
    if !isnothing(ss)
        ssname = propertynames(ss)
        for ssn ∈ ssname
            ss_r = getproperty(ss, ssn)
            ss_range = ss_r[1]:ss_r[2]
            v = spatialSubset(v, ss_range, Val(ssn))
        end
    end
    return v
end

"""
    getCombinedVariableInfo(default_info::NamedTuple, var_info::NamedTuple)

combines the property values of the default with the properties set for the particular variable

"""
function getCombinedVariableInfo(default_info::NamedTuple, var_info::NamedTuple)
    combined_info = (;)
    default_fields = propertynames(default_info)
    var_fields = propertynames(var_info)
    all_fields = Tuple(unique([default_fields..., var_fields...]))
    for var_field ∈ all_fields
        field_value = nothing
        if hasproperty(default_info, var_field)
            field_value = getfield(default_info, var_field)
        else
            field_value = getfield(var_info, var_field)
        end
        if hasproperty(var_info, var_field)
            var_prop = getfield(var_info, var_field)
            if !isnothing(var_prop) && length(var_prop) > 0
                field_value = getfield(var_info, var_field)
            end
        end
        combined_info = setTupleField(combined_info,
            (var_field, field_value))
    end
    return combined_info
end



"""
    applyQCBound(data_in, data_qc, bounds_qc, dfill)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""
"""
    applyQCBound(data_in, data_qc, bounds_qc, dfill)

DOCSTRING

# Arguments:
- `data_in`: DESCRIPTION
- `data_qc`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
- `dfill`: DESCRIPTION
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
"""
    applyUnitConversion(data_in, conversion, isadditive = false)

DOCSTRING

# Arguments:
- `data_in`: DESCRIPTION
- `conversion`: DESCRIPTION
- `isadditive`: DESCRIPTION
"""
function applyUnitConversion(data_in, conversion, isadditive=false)
    if isadditive
        data_out = data_in + conversion
    else
        data_out = data_in * conversion
    end
    return data_out
end

"""
    mapCleanData(yax, yax_qc, dfill, bounds_qc, vinfo, nothing::Val{T})

DOCSTRING

# Arguments:
- `yax`: DESCRIPTION
- `yax_qc`: DESCRIPTION
- `dfill`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
- `vinfo`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function mapCleanData(yax, yax_qc, dfill, bounds_qc, vinfo, ::Val{T}) where {T}
    if !isnothing(bounds_qc) && !isnothing(yax_qc)
        yax = map((da, dq) -> applyQCBound(da, dq, bounds_qc, dfill), yax, yax_qc)
    end
    vT = Val{T}()
    yax = map(yax_point -> cleanData(yax_point, dfill, vinfo, vT), yax)
    return yax
end

"""
    isInvalid(num)

DOCSTRING
"""
function isInvalid(num)
    return isnothing(num) || ismissing(num) || isnan(num) || isinf(num)
end

"""
    cleanInvalid(yax_point, dfill)

DOCSTRING
"""
function cleanInvalid(yax_point, dfill)
    yax_point = isInvalid(yax_point) ? dfill : yax_point
    return yax_point
end

"""
    cleanData(yax_point, dfill, vinfo, nothing::Val{T})

DOCSTRING

# Arguments:
- `yax_point`: DESCRIPTION
- `dfill`: DESCRIPTION
- `vinfo`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
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
    getDataDims(c, mappinginfo)

DOCSTRING
"""
function getDataDims(c, mappinginfo)
    inax = []
    axnames = DimensionalData.name(dims(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    return InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

"""
    getNumberOfTimeSteps(incubes, time_name)

DOCSTRING
"""
function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    return length(getAxis(time_name, incubes[i1]).values)
end

"""
    getForcingTimeSize(forcing::NamedTuple)

DOCSTRING
"""
function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v ∈ forcing
        if in(:time, AxisKeys.dimnames(v))
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

"""
    getForcingTimeSize(forcing, nothing::Val{forc_vars})

DOCSTRING
"""
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

"""
    getForcingForTimeStep(forcing, f_t, ts, nothing::Val{forc_vars})

DOCSTRING

# Arguments:
- `forcing`: DESCRIPTION
- `f_t`: DESCRIPTION
- `ts`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
@generated function getForcingForTimeStep(forcing, f_t, ts, ::Val{forc_vars}) where {forc_vars}
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

"""
    getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)

DOCSTRING

# Arguments:
- `forcing`: DESCRIPTION
- `forcing_t`: DESCRIPTION
- `ts`: DESCRIPTION
"""
function getForcingForTimeStep(forcing::NamedTuple, forcing_t, ts::Int64)
    for f ∈ keys(forcing)
        v = forcing[f]
        forcing_t = @set forcing_t[f] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
    return forcing_t
end

"""
    getForcingForTimeStep(forcing::NamedTuple, ts::Int64)

DOCSTRING
"""
function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

"""
filterVariables(out::NamedTuple, varsinfo; filter_variables=true)
"""
"""
    filterVariables(out::NamedTuple, varsinfo::NamedTuple; filter_variables = true)

DOCSTRING

# Arguments:
- `out`: DESCRIPTION
- `varsinfo`: DESCRIPTION
- `filter_variables`: DESCRIPTION
"""
function filterVariables(out::NamedTuple, varsinfo::NamedTuple; filter_variables=true)
    if !filter_variables
        fout = out
    else
        fout = (;)
        for k ∈ keys(varsinfo)
            v = getfield(varsinfo, k)
            fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
        end
    end
    return fout
end

"""
getNamedDimsArrayWithNames(input::NamedTuple)
"""
"""
    getNamedDimsArrayWithNames(input)

DOCSTRING
"""
function getNamedDimsArrayWithNames(input)
    ks = input.variables
    keyedData = map(input.data) do c
        t_dims = getSindbadDims(c)
        NamedDimsArray(Array(c.data); t_dims...)
    end
    return (; Pair.(ks, keyedData)...)
end

"""
getSindbadDims(c)
prepare the dimensions of data and name them appropriately for use in internal SINDBAD functions
"""
"""
    getSindbadDims(c)

DOCSTRING
"""
function getSindbadDims(c)
    dimnames = DimensionalData.name(dims(c))
    act_dimnames = []
    foreach(dimnames) do dimn
        td = dimn
        if dimn in (:Ti, :Time, :TIME, :t, :T, :TI)
            td = :time
        end
        push!(act_dimnames, td)
    end
    return [act_dimnames[k] => getproperty(c, dimnames[k]) |> Array for k ∈ eachindex(dimnames)]
end

"""
getKeyedArrayWithNames(input::NamedTuple)
"""
"""
    getKeyedArrayWithNames(input)

DOCSTRING
"""
function getKeyedArrayWithNames(input)
    ks = input.variables
    keyedData = getKeyedArray(input)
    return (; Pair.(ks, keyedData)...)
end


"""
getKeyedArray(input::NamedTuple)
"""
"""
    getKeyedArray(input)

DOCSTRING
"""
function getKeyedArray(input)
    keyedData = map(input.data) do c
        t_dims = getSindbadDims(c)
        KeyedArray(Array(c.data); t_dims...)
    end
    return keyedData
end


"""
getKeyedArray(input::NamedTuple)
"""
"""
    getArray(input)

DOCSTRING
"""
function getArray(input)
    arrayData = map(input.data) do c
        Array(c.data)
    end
    return arrayData
end

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
Base.getproperty(s::landWrapper, f::Symbol) = GroupView(f, getfield(s, :s))
"""
    Base.getproperty(g::GroupView, f::Symbol)

DOCSTRING
"""
function Base.getproperty(g::GroupView, f::Symbol)
    allarrays = getfield(g, :s)
    groupname = getfield(g, :groupname)
    T = typeof(first(allarrays)[groupname][f])
    return ArrayView{T,ndims(allarrays),typeof(allarrays)}(allarrays, groupname, f)
end
Base.size(a::ArrayView) = size(a.s)
Base.IndexStyle(a::Type{<:ArrayView}) = IndexLinear()
Base.getindex(a::ArrayView, i::Int) = a.s[i][a.groupname][a.arrayname]
Base.propertynames(o::landWrapper) = propertynames(first(getfield(o, :s)))
Base.keys(o::landWrapper) = propertynames(o)
Base.getindex(o::landWrapper, s::Symbol) = getproperty(o, s)
"""
    Base.propertynames(o::GroupView)

DOCSTRING
"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)


## temporal aggregators
"""
    Base.view(x::AbstractArray, v::Sindbad.TimeAggregator; dim = 1)

DOCSTRING

# Arguments:
- `x`: DESCRIPTION
- `v`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function Base.view(x::AbstractArray, v::Sindbad.TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.f, subarray_t)
    Sindbad.TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end

"""
    getTimeAggrArray(_dat::AbstractArray{T, 2})

DOCSTRING
"""
function getTimeAggrArray(_dat::AbstractArray{T,2}) where {T}
    return _dat[:, :]
end

"""
    getTimeAggrArray(_dat::AbstractArray{T, 3})

DOCSTRING
"""
function getTimeAggrArray(_dat::AbstractArray{T,3}) where {T}
    return _dat[:, :, :]
end

"""
    getTimeAggrArray(_dat::AbstractArray{T, 4})

DOCSTRING
"""
function getTimeAggrArray(_dat::AbstractArray{T,4}) where {T}
    return _dat[:, :, :, :]
end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::AxisKeys.KeyedArray, temporal_aggregator::Sindbad.TimeAggregator, dim = 1)

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat::AxisKeys.KeyedArray, temporal_aggregator::Sindbad.TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::AbstractArray, temporal_aggregator::Sindbad.TimeAggregator, dim = 1)

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat::AbstractArray, temporal_aggregator::Sindbad.TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::SubArray, temporal_aggregator::Sindbad.TimeAggregator, dim = 1)

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat::SubArray, temporal_aggregator::Sindbad.TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

# works for everything for which no aggregation is needed
"""
    temporalAggregation(dat, temporal_aggregator::Nothing, dim = 1)

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregator::Nothing, dim=1)
    return dat
end

"""
    temporalAggregation(dat, temporal_aggregators, nothing::Val{:no_diff})

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregators`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregators, ::Val{:no_diff})
    return temporalAggregation(dat, first(temporal_aggregators))
end

"""
    temporalAggregation(dat, temporal_aggregators, nothing::Val{:diff})

DOCSTRING

# Arguments:
- `dat`: DESCRIPTION
- `temporal_aggregators`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregators, ::Val{:diff})
    dat_agg = temporalAggregation(dat, first(temporal_aggregators))
    dat_agg_to_remove = temporalAggregation(dat, last(temporal_aggregators))
    return dat_agg .- dat_agg_to_remove
end
