export AllNaN
export mapCleanData
export subsetAndProcessYax
export cube_to_KA

"""
    AllNaN <: YAXArrays.DAT.ProcFilter

Add skipping filter for pixels with all nans in YAXArrays
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)


"""
    applyQCBound(_data, data_qc, bounds_qc, _data_fill)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag

# Arguments:
- `_data`: data to check
- `data_qc`: data of quality flag
- `bounds_qc`: validity bounds of quality flag
- `_data_fill`: data to replace with in case outside quality bounds
"""
function applyQCBound(_data, data_qc, bounds_qc, _data_fill)
    _data_out = _data
    if data_qc < first(bounds_qc) || data_qc > last(bounds_qc)
        _data_out = _data_fill
    end
    return _data_out
end


"""
    applyUnitConversion(_data, conversion, isadditive = false)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag

# Arguments:
- `_data`: data to convert
- `conversion`: conversion factor
- `isadditive`: whether to apply the factor as addition or multiplication
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
    cleanData(_data, _data_fill, _data_info, Val{T})



# Arguments:
- `_data`: data to clean
- `_data_fill`: value for filling invalid data
- `_data_info`: information of data such as bounds and unit conversion factors
- `::Val{T}`: type converter for data
"""
function cleanData(_data, _data_fill, _data_info, ::Val{T}) where {T}
    _data = replaceInvalid(_data, _data_fill)
    _data = applyUnitConversion(_data, _data_info.source_to_sindbad_unit,
        _data_info.additive_unit_conversion)
    bounds = _data_info.bounds
    if !isnothing(bounds)
        _data = clamp(_data, first(bounds), last(bounds))
    end
    return T(_data)
end


"""
    getDataDims(c, mappinginfo)


"""
function getDataDims(c, mappinginfo)
    inax = []
    axnames = DimensionalData.name(dims(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    return InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

"""
    getDimPermutation(datDims, permDims)


"""
function getDimPermutation(datDims, permDims)
    new_dim = Int[]
    for pd ∈ permDims
        datIndex = length(permDims)
        if pd in datDims
            datIndex = findfirst(isequal(pd), datDims)
        end
        push!(new_dim, datIndex)
    end
    return new_dim
end

"""
    getInputArrayOfType(input_data, ::InputArray})


"""
function getInputArrayOfType(input_data, ::InputArray)
    array_data = map(input_data) do c
        Array(c.data)
    end
    return array_data
end

"""
    getInputArrayOfType(input_data, ::InputKeyedArray})


"""
function getInputArrayOfType(input_data, ::InputKeyedArray)
    keyed_array_data = map(input_data) do c
        t_dims = getSindbadDims(c)
        KeyedArray(Array(c.data); t_dims...)
    end
    return keyed_array_data
end

"""
    getInputArrayOfType(input_data, ::InputNamedDimsArray})


"""
function getInputArrayOfType(input_data, ::InputNamedDimsArray)
    named_array_data = map(input_data) do c
        t_dims = getSindbadDims(c)
        NamedDimsArray(Array(c.data); t_dims...)
    end
    return named_array_data
end

"""
    getInputArrayOfType(input_data, ::InputYaxArray})


"""
function getInputArrayOfType(input_data, ::InputYaxArray)
    return input_data
end


"""
    getSindbadDims(c)

prepare the dimensions of data and name them appropriately for use in internal SINDBAD functions
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
    getTargetDimensionOrder(info)


"""
function getTargetDimensionOrder(info)
    tar_dims = nothing
    if !isnothing(info.forcing.data_dimension.permute)
        tar_dims = Symbol[]
        for pd ∈ info.forcing.data_dimension.permute
            tdn = Symbol(pd)
            push!(tar_dims, tdn)
        end
    end
    return tar_dims
end

"""
    getYaxFromSource(nc, data_path, data_path_v, source_variable, info, ::BackendNetcdf)



# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `data_path_v`: DESCRIPTION
- `source_variable`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `::BackendNetcdf`: DESCRIPTION
"""
function getYaxFromSource(nc, data_path, data_path_v, source_variable, info, ::BackendNetcdf)
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    v = nc[source_variable]
    ax = map(NCDatasets.dimnames(v)) do dn
        rax = nothing
        if dn == info.forcing.data_dimension.time
            t = nc[info.forcing.data_dimension.time]
            t = [_t for _t in t]
            rax = Dim{Symbol(dn)}(t)
        else
            if dn in keys(nc)
                dv = info.tem.helpers.numbers.sNT.(nc[dn][:])
            else
                error("To avoid possible issues with dimensions, Sindbad does not run when the dimension variable $(dn) is not available in input data file $(data_path). Add the variable to the data, and try again.")
            end
            rax = Dim{Symbol(dn)}(dv)
        end
        rax
    end
    yax = YAXArray(Tuple(ax), v[:])
    return nc, yax
end

"""
    getYaxFromSource(nc, data_path, data_path_v, source_variable, _, ::BackendZarr)



# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `data_path_v`: DESCRIPTION
- `source_variable`: DESCRIPTION
- `_`: unused argument
- `::BackendZarr`: DESCRIPTION
"""
function getYaxFromSource(nc, data_path, data_path_v, source_variable, _, ::BackendZarr)
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    yax = nc[source_variable]
    return nc, yax
end

"""
    loadDataFile(data_path)


"""
function loadDataFile(data_path)
    if endswith(data_path, ".nc")
        nc = NCDataset(data_path)
    elseif endswith(data_path, ".zarr")
        nc = YAXArrays.open_dataset(zopen(data_path))
    else
        error("The file ending/data type is not supported for $(datapath). Either use .nc or .zarr file")
    end
    return nc
end

"""
    loadDataFromPath(nc, data_path, data_path_v, source_variable)



# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `data_path_v`: DESCRIPTION
- `source_variable`: DESCRIPTION
"""
function loadDataFromPath(nc, data_path, data_path_v, source_variable)
    if isnothing(data_path_v) || (data_path_v === data_path)
        nc = nc
    else
        @info "   data_path: $(data_path_v)"
        nc = loadDataFile(data_path_v)
    end
    return nc
end

"""
    mapCleanData(_data, _data_qc, _data_fill, bounds_qc, _data_info, Val{T})



# Arguments:
- `_data`: DESCRIPTION
- `_data_qc`: DESCRIPTION
- `_data_fill`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
- `_data_info`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function mapCleanData(_data, _data_qc, _data_fill, bounds_qc, _data_info, ::Val{T}) where {T}
    if !isnothing(bounds_qc) && !isnothing(_data_qc)
        _data = map((da, dq) -> applyQCBound(da, dq, bounds_qc, _data_fill), _data, _data_qc)
    end
    vT = Val{T}()
    _data = map(data_point -> cleanData(data_point, _data_fill, _data_info, vT), _data)
    return _data
end


"""
    subsetAndProcessYax(yax, forcing_mask, tar_dims, _data_info, info, Val{num_type}; clean_data = true, fill_nan = false, yax_qc = nothing, bounds_qc = nothing)



# Arguments:
- `yax`: DESCRIPTION
- `forcing_mask`: DESCRIPTION
- `tar_dims`: DESCRIPTION
- `_data_info`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `nothing`: DESCRIPTION
- `clean_data`: DESCRIPTION
- `fill_nan`: DESCRIPTION
- `yax_qc`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
"""
function subsetAndProcessYax(yax, forcing_mask, tar_dims, _data_info, info, ::Val{num_type}; clean_data=true, fill_nan=false, yax_qc=nothing, bounds_qc=nothing) where {num_type}

    if !isnothing(forcing_mask)
        yax = yax #todo: mask the forcing variables here depending on the mask of 1 and 0
    end

    if !isnothing(tar_dims)
        permutes = getDimPermutation(YAXArrayBase.dimnames(yax), tar_dims)
        @debug "         -> permuting dimensions to $(tar_dims)..."
        yax = permutedims(yax, permutes)
    end
    if hasproperty(yax, Symbol(info.forcing.data_dimension.time))
        init_date = DateTime(info.tem.helpers.dates.date_begin)
        last_date = DateTime(info.tem.helpers.dates.date_end) + info.tem.helpers.dates.timestep
        yax = yax[time=(init_date .. last_date)]
    end

    if hasproperty(info.forcing, :subset)
        yax = getSpatialSubset(info.forcing.subset, yax)
    end

    #todo mean of the data instead of zero or nan
    vfill = num_type(0.0)
    if fill_nan
        vfill = num_type(NaN)
    end
    vNT = Val{num_type}()
    if clean_data
        yax = mapCleanData(yax, yax_qc, vfill, bounds_qc, _data_info, vNT)
    else
        yax = map(yax_point -> replaceInvalid(yax_point, vfill), yax)
        yax = num_type.(yax)
    end
    return yax
end

"""
cube_to_KA(c)
"""
function cube_to_KA(c)
    t_dims = getSindbadDims(c);
    return KeyedArray(Array(c.data); t_dims...)
end
