export booleanizeMask
export cleanData
export filterVariables
export getArray
export getAbsDataPath
export getCombinedVariableInfo
export getDataDims
export getSpatialSubset
export getSindbadDims
export isInvalid
export landWrapper
export mapCleanData
export temporalAggregation

export createTimeAggregator
export TimeAggregator
export TimeAggregatorViewInstance



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

DOCSTRING
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

DOCSTRING
"""
function Base.propertynames(o::GroupView)
    return propertynames(first(getfield(o, :s))[getfield(o, :groupname)])
end
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView, i::Symbol) = getproperty(o, i)


"""
    TimeAggregator{I, aggr_func}

DOCSTRING

# Fields:
- `indices::I`: DESCRIPTION
- `aggr_func::aggr_func`: DESCRIPTION
"""
struct TimeAggregator{I,aggr_func}
    indices::I
    aggr_func::aggr_func
end

"""
    booleanizeMask(yax_mask)

DOCSTRING
"""
function booleanizeMask(yax_mask)
    _data_fill = 0.0
    yax_mask = map(_data -> cleanInvalid(_data, _data_fill), yax_mask)
    yax_mask_bits = all.(>(_data_fill), yax_mask)
    return yax_mask_bits
end

"""
    spatialSubset(v, ss_range, Val{:site})

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
    spatialSubset(v, ss_range, Val{:lat})

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
    spatialSubset(v, ss_range, Val{:latitude})

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
    spatialSubset(v, ss_range, Val{:lon})

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
    spatialSubset(v, ss_range, Val{:longitude})

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
    spatialSubset(v, ss_range, Val{:id})

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
    spatialSubset(v, ss_range, Val{:Id})

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
    spatialSubset(v, ss_range, Val{:ID})

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
    applyQCBound(_data, data_qc, bounds_qc, _data_fill)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""

"""
    applyQCBound(_data, data_qc, bounds_qc, _data_fill)

DOCSTRING

# Arguments:
- `_data`: DESCRIPTION
- `data_qc`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
- `_data_fill`: DESCRIPTION
"""
function applyQCBound(_data, data_qc, bounds_qc, _data_fill)
    _data_out = _data
    if data_qc < first(bounds_qc) || data_qc > last(bounds_qc)
        _data_out = _data_fill
    end
    return _data_out
end

"""
    applyUnitConversion(_data, conversion, isadditive=false)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""

"""
    applyUnitConversion(_data, conversion, isadditive = false)

DOCSTRING

# Arguments:
- `_data`: DESCRIPTION
- `conversion`: DESCRIPTION
- `isadditive`: DESCRIPTION
"""
function applyUnitConversion(_data, conversion, isadditive=false)
    if isadditive
        _data_out = _data + conversion
    else
        _data_out = _data * conversion
    end
    return _data_out
end

"""
    mapCleanData(yax, yax_qc, _data_fill, bounds_qc, vinfo, Val{T})

DOCSTRING

# Arguments:
- `yax`: DESCRIPTION
- `yax_qc`: DESCRIPTION
- `_data_fill`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
- `vinfo`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function mapCleanData(yax, yax_qc, _data_fill, bounds_qc, vinfo, ::Val{T}) where {T}
    if !isnothing(bounds_qc) && !isnothing(yax_qc)
        yax = map((da, dq) -> applyQCBound(da, dq, bounds_qc, _data_fill), yax, yax_qc)
    end
    vT = Val{T}()
    yax = map(_data -> cleanData(_data, _data_fill, vinfo, vT), yax)
    return yax
end

"""
    isInvalid(num)

DOCSTRING
"""
function isInvalid(_data)
    return isnothing(_data) || ismissing(_data) || isnan(_data) || isinf(_data)
end

"""
    cleanInvalid(_data, _data_fill)

DOCSTRING
"""
function cleanInvalid(_data, _data_fill)
    _data = isInvalid(_data) ? _data_fill : _data
    return _data
end

"""
    cleanData(_data, _data_fill, vinfo, Val{T})

DOCSTRING

# Arguments:
- `_data`: DESCRIPTION
- `_data_fill`: DESCRIPTION
- `vinfo`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function cleanData(_data, _data_fill, vinfo, ::Val{T}) where {T}
    _data = cleanInvalid(_data, _data_fill)
    _data = applyUnitConversion(_data, vinfo.source_to_sindbad_unit,
        vinfo.additive_unit_conversion)
    bounds = vinfo.bounds
    if !isnothing(bounds)
        _data = clamp(_data, first(bounds), last(bounds))
    end
    return T(_data)
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



## temporal aggregators
"""
    Base.view(x::AbstractArray, v::TimeAggregator; dim = 1)

DOCSTRING

# Arguments:
- `x`: DESCRIPTION
- `v`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function Base.view(x::AbstractArray, v::TimeAggregator; dim=1)
    subarray_t = Base.promote_op(getindex, typeof(x), eltype(v.indices))
    t = Base.promote_op(v.aggr_func, subarray_t)
    TimeAggregatorViewInstance{t,ndims(x),dim,typeof(x),typeof(v)}(x, v, Val{dim}())
end

"""
    getTimeAggrArray(_dat::AbstractArray{T, 2})

DOCSTRING
"""
function getTimeAggrArray(_dat::AbstractArray{T,2}) where {T}
    return _dat[:, :]
end

# function getTimeAggrArray(_dat::AbstractArray{<:Any,N}) where N
#     inds = ntuple(_->Colon(),N)
#     inds = map(size(_data)) do _
#         Colon()
#     end
#     _dat[inds...]
# end

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

# # works for everything for which aggregator is needed
# """
#     temporalAggregation(dat::AxisKeys.KeyedArray, temporal_aggregator::TimeAggregator, dim = 1)

# DOCSTRING

# # Arguments:
# - `dat`: a data array/vector to aggregate
# - `temporal_aggregator`: DESCRIPTION
# - `dim`: DESCRIPTION
# """
# function temporalAggregation(dat, temporal_aggregator::TimeAggregator, dim=1)
#     dat = view(dat, temporal_aggregator, dim=dim)
#     return dat
# end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim = 1)

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return dat
end

# works for everything for which aggregator is needed
"""
    temporalAggregation(dat::SubArray, temporal_aggregator::TimeAggregator, dim = 1)

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat::SubArray, temporal_aggregator::TimeAggregator, dim=1)
    dat = view(dat, temporal_aggregator, dim=dim)
    return getTimeAggrArray(dat)
end

# works for everything for which no aggregation is needed
"""
    temporalAggregation(dat, temporal_aggregator::Nothing, dim = 1)

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregator`: DESCRIPTION
- `dim`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregator::Nothing, dim=1)
    return dat
end

"""
    temporalAggregation(dat, temporal_aggregators, Val{:no_diff})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregators`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregators, ::Val{:no_diff})
    return temporalAggregation(dat, first(temporal_aggregators))
end

"""
    temporalAggregation(dat, temporal_aggregators, Val{:diff})

DOCSTRING

# Arguments:
- `dat`: a data array/vector to aggregate
- `temporal_aggregators`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function temporalAggregation(dat, temporal_aggregators, ::Val{:diff})
    dat_agg = temporalAggregation(dat, first(temporal_aggregators))
    dat_agg_to_remove = temporalAggregation(dat, last(temporal_aggregators))
    return dat_agg .- dat_agg_to_remove
end

## base structs/functions for time aggregators


"""
    getIndicesForTimeGroups(groups)

DOCSTRING
"""
function getIndicesForTimeGroups(groups)
    _, rl = rle(groups)
    cums = [0; cumsum(rl)]
    stepvectime = [cums[i]+1:cums[i+1] for i in 1:length(rl)]
    return stepvectime
end


"""
    TimeAggregatorViewInstance{T, N, D, P, AV <: TimeAggregator}

DOCSTRING

# Fields:
- `parent::P`: DESCRIPTION
- `agg::AV`: DESCRIPTION
- `dim::Val{D}`: DESCRIPTION
"""
struct TimeAggregatorViewInstance{T,N,D,P,AV<:TimeAggregator} <: AbstractArray{T,N}
    parent::P
    agg::AV
    dim::Val{D}
end

"""
    getdim(a::TimeAggregatorViewInstance{<:Any, <:Any, D})

DOCSTRING
"""
getdim(a::TimeAggregatorViewInstance{<:Any,<:Any,D}) where {D} = D

"""
    Base.size(a::TimeAggregatorViewInstance, i)

DOCSTRING
"""
function Base.size(a::TimeAggregatorViewInstance, i)
    if i === getdim(a)
        size(a.agg.indices, 1)
    else
        size(a.parent, i)
    end
end

Base.size(a::TimeAggregatorViewInstance) = ntuple(i -> size(a, i), ndims(a))
"""
    Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int, N})

DOCSTRING
"""
function Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int,N}) where {N}
    idim = getdim(a)
    indices = I
    indices = Base.setindex(indices, a.agg.indices[I[idim]], idim)
    a.agg.aggr_func(view(a.parent, indices...))
end

"""
    getArType()

DOCSTRING
"""
function getArType()
    return Val(:array)
    # return Val(:sized_array)
end

"""
    getTimeArray(ar, Val{:sized_array})

DOCSTRING
"""
function getTimeArray(ar, ::Val{:sized_array})
    return SizedArray{Tuple{size(ar)...},eltype(ar)}(ar)
end

"""
    getTimeArray(ar, Val{:array})

DOCSTRING
"""
function getTimeArray(ar, ::Val{:array})
    return ar
end

## time aggregators for model output and observations
"""
    createTimeAggregator(date_vector, t_step::Symbol, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `t_step`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, t_step::Symbol, aggr_func=mean, is_model_timestep=false)
    return createTimeAggregator(date_vector, Val(t_step), aggr_func, is_model_timestep)
end

"""
    createTimeAggregator(date_vector, Val{:mean}, aggr_func = mean)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:mean}, aggr_func=mean)
    stepvectime = getTimeArray([1:length(date_vector)], getArType())
    mean_agg = TimeAggregator(stepvectime, aggr_func)
    return [mean_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:day}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:day}, aggr_func=mean, is_model_timestep=false)
    stepvectime = [getTimeArray([t], getArType()) for t in 1:length(date_vector)]
    day_agg = TimeAggregator(stepvectime, aggr_func)
    if is_model_timestep
        day_agg = nothing
    end
    return [day_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:day_anomaly}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:day_anomaly}, aggr_func=mean, is_model_timestep=false)
    day_agg = createTimeAggregator(date_vector, Val(:day), aggr_func, is_model_timestep)
    mean_agg = createTimeAggregator(date_vector, Val(:mean), aggr_func)
    return [day_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, Val{:day_iav}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:day_iav}, aggr_func=mean, is_model_timestep=false)
    days = dayofyear.(date_vector)
    day_aggr = createTimeAggregator(date_vector, Val(:day), aggr_func, is_model_timestep)
    days_msc = unique(days)
    days_msc_inds = [findall(==(dd), days) for dd in days_msc]
    days_iav_inds = [getTimeArray(days_msc_inds[d], getArType()) for d in days]
    day_iav_agg = TimeAggregator(days_iav_inds, aggr_func)
    return [day_aggr[1], day_iav_agg]
end

"""
    createTimeAggregator(date_vector, Val{:day_msc}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:day_msc}, aggr_func=mean, is_model_timestep=false)
    days = dayofyear.(date_vector)
    days_msc = unique(days)
    days_ind = [getTimeArray(findall(==(dd), days), getArType()) for dd in days_msc]
    day_msc_agg = TimeAggregator(days_ind, aggr_func)
    return [day_msc_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:day_msc_anomaly}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:day_msc_anomaly}, aggr_func=mean, is_model_timestep=false)
    day_msc_agg = createTimeAggregator(date_vector, Val(:day_msc), aggr_func, is_model_timestep)
    mean_agg = createTimeAggregator(date_vector, Val(:mean), aggr_func)
    return [day_msc_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, Val{:month}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:month}, aggr_func=mean, is_model_timestep=false)
    stepvectime = getIndicesForTimeGroups(month.(date_vector))
    month_agg = TimeAggregator(stepvectime, aggr_func)
    return [month_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:month_anomaly}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:month_anomaly}, aggr_func=mean, is_model_timestep=false)
    month_agg = createTimeAggregator(date_vector, Val(:month), aggr_func, is_model_timestep)
    mean_agg = createTimeAggregator(date_vector, Val(:mean), aggr_func)
    return [month_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, Val{:month_iav}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:month_iav}, aggr_func=mean, is_model_timestep=false)
    months = month.(date_vector) # month for each time step, size = number of time steps
    month_aggr = createTimeAggregator(date_vector, Val(:month), aggr_func, is_model_timestep) #to get the month per month, size = number of months
    months_series = Int.(view(months, month_aggr[1])) # aggregate the months per time step
    months_msc = unique(months) # get unique months
    months_msc_inds = [findall(==(mm), months) for mm in months_msc] # all timesteps per unique month
    months_iav_inds = [getTimeArray(months_msc_inds[mm], getArType()) for mm in months_series] # repeat monthlymsc indices for each month in time range
    month_iav_agg = TimeAggregator(months_iav_inds, aggr_func) # generate aggregator
    return [month_aggr[1], month_iav_agg]
end

"""
    createTimeAggregator(date_vector, Val{:month_msc}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:month_msc}, aggr_func=mean, is_model_timestep=false)
    months = month.(date_vector)
    months_msc = unique(months)
    month_msc_agg = TimeAggregator([getTimeArray(findall(==(mm), months), getArType()) for mm in months_msc], aggr_func)
    return [month_msc_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:month_msc_anomaly}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:month_msc_anomaly}, aggr_func=mean, is_model_timestep=false)
    month_msc_agg = createTimeAggregator(date_vector, Val(:month_msc), aggr_func, is_model_timestep)
    mean_agg = createTimeAggregator(date_vector, Val(:mean), aggr_func)
    return [month_msc_agg[1], mean_agg[1]]
end

"""
    createTimeAggregator(date_vector, Val{:year}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:year}, aggr_func=mean, is_model_timestep=false)
    stepvectime = getTimeArray(getIndicesForTimeGroups(year.(date_vector)), getArType())
    year_agg = TimeAggregator(stepvectime, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:year_anomaly}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:year_anomaly}, aggr_func=mean, is_model_timestep=false)
    year_agg = createTimeAggregator(date_vector, Val(:year), aggr_func, is_model_timestep)
    mean_agg = createTimeAggregator(date_vector, Val(:mean), aggr_func)
    return [year_agg[1], mean_agg[1]]
end

## spinup forcing related aggregators and functions
"""
    getIndexForSelectedYear(years, sel_year)

DOCSTRING
"""
function getIndexForSelectedYear(years, sel_year)
    return getTimeArray(findall(==(sel_year), years), getArType())
end

"""
    createTimeAggregator(date_vector, Val{:all_years}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:all_years}, aggr_func=mean, is_model_timestep=false)
    stepvectime = getTimeArray([1:length(date_vector)], getArType())
    all_agg = TimeAggregator(stepvectime, aggr_func)
    return [all_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:first_year}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:first_year}, aggr_func=mean, is_model_timestep=false)
    years = year.(date_vector)
    first_year = minimum(years)
    year_inds = getIndexForSelectedYear(years, first_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:random_year}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:random_year}, aggr_func=mean, is_model_timestep=false)
    years = year.(date_vector)
    random_year = rand(unique(years))
    year_inds = getIndexForSelectedYear(years, random_year)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

"""
    createTimeAggregator(date_vector, Val{:shuffle_years}, aggr_func = mean, is_model_timestep = false)

DOCSTRING

# Arguments:
- `date_vector`: DESCRIPTION
- `nothing`: DESCRIPTION
- `aggr_func`: DESCRIPTION
- `is_model_timestep`: DESCRIPTION
"""
function createTimeAggregator(date_vector, ::Val{:shuffle_years}, aggr_func=mean, is_model_timestep=false)
    years = year.(date_vector)
    unique_years = unique(years)
    shuffled_unique_years = sample(unique_years, length(unique_years), replace=false)
    year_inds = getIndexForSelectedYear.(Ref(years), shuffled_unique_years)
    year_agg = TimeAggregator(year_inds, aggr_func)
    return [year_agg,]
end

