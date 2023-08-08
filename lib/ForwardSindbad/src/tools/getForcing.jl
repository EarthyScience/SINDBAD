export getForcing, getDimPermutation, loadDataFile
export getYaxFromSource


"""
    getDimPermutation(datDims, permDims)

DOCSTRING
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
    collectForcingSizes(info, in_yax)

DOCSTRING
"""
function collectForcingSizes(info, in_yax)
    time_dim_name = Symbol(info.forcing.data_dimension.time)
    dnames = Symbol[]
    dsizes = []
    push!(dnames, time_dim_name)
    if time_dim_name in in_yax
        push!(dsizes, length(getproperty(in_yax, time_dim_name)))
    else
        push!(dsizes, length(DimensionalData.lookup(in_yax, time_dim_name)))
    end
    for space ∈ info.forcing.data_dimension.space
        push!(dnames, Symbol(space))
        push!(dsizes, length(getproperty(in_yax, Symbol(space))))
    end
    f_sizes = (; Pair.(dnames, dsizes)...)
    return f_sizes
end

"""
    collectForcingHelpers(info, f_sizes, f_dimensions)

DOCSTRING

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `f_sizes`: DESCRIPTION
- `f_dimensions`: DESCRIPTION
"""
function collectForcingHelpers(info, f_sizes, f_dimensions)
    f_helpers = (;)
    f_helpers = setTupleField(f_helpers, (:dimensions, info.forcing.data_dimension))
    f_helpers = setTupleField(f_helpers, (:axes, f_dimensions))
    if hasproperty(info.forcing, :subset)
        f_helpers = setTupleField(f_helpers, (:subset, info.forcing.subset))
    else
        f_helpers = setTupleField(f_helpers, (:subset, nothing))
    end
    f_helpers = setTupleField(f_helpers, (:sizes, f_sizes))
    return f_helpers
end

"""
    subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info, nothing::Val{num_type}; clean_data = true, fill_nan = false, yax_qc = nothing, bounds_qc = nothing)

DOCSTRING

# Arguments:
- `yax`: DESCRIPTION
- `forcing_mask`: DESCRIPTION
- `tar_dims`: DESCRIPTION
- `vinfo`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `nothing`: DESCRIPTION
- `clean_data`: DESCRIPTION
- `fill_nan`: DESCRIPTION
- `yax_qc`: DESCRIPTION
- `bounds_qc`: DESCRIPTION
"""
function subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info, ::Val{num_type}; clean_data=true, fill_nan=false, yax_qc=nothing, bounds_qc=nothing) where {num_type}

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
        yax = mapCleanData(yax, yax_qc, vfill, bounds_qc, vinfo, vNT)
    else
        yax = map(yax_point -> cleanInvalid(yax_point, vfill), yax)
        yax = num_type.(yax)
    end
    return yax
end

"""
    getForcingNamedTuple(incubes, f_sizes, f_dimensions, info)

DOCSTRING

# Arguments:
- `incubes`: DESCRIPTION
- `f_sizes`: DESCRIPTION
- `f_dimensions`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
function getForcingNamedTuple(incubes, f_sizes, f_dimensions, info)
    @info "   processing forcing helpers..."
    @debug "     ::dimensions::"
    indims = getDataDims.(incubes, Ref(Symbol.(info.forcing.data_dimension.space)))
    @debug "     ::variable names::"
    forcing_variables = keys(info.forcing.variables)
    f_helpers = collectForcingHelpers(info, f_sizes, f_dimensions)
    @info "\n----------------------------------------------\n"
    forcing = (;
        data=incubes,
        dims=indims,
        variables=forcing_variables,
        helpers=f_helpers)
    return forcing
end

"""
    getTargetDimensionOrder(info)

DOCSTRING
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
    loadDataFile(data_path)

DOCSTRING
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

DOCSTRING

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
    getYaxFromSource(nc, data_path, data_path_v, source_variable, info, nothing::Val{:netcdf})

DOCSTRING

# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `data_path_v`: DESCRIPTION
- `source_variable`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `nothing`: DESCRIPTION
"""
function getYaxFromSource(nc, data_path, data_path_v, source_variable, info, ::Val{:netcdf})
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    v = nc[source_variable]
    ax = map(NCDatasets.dimnames(v)) do dn
        rax = nothing
        if dn == info.forcing.data_dimension.time
            t = nc[info.forcing.data_dimension.time]
            rax = Dim{Symbol(dn)}(t[:])
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
    getYaxFromSource(nc, data_path, data_path_v, source_variable, _, nothing::Val{:zarr})

DOCSTRING

# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `data_path_v`: DESCRIPTION
- `source_variable`: DESCRIPTION
- `_`: unused argument
- `nothing`: DESCRIPTION
"""
function getYaxFromSource(nc, data_path, data_path_v, source_variable, _, ::Val{:zarr})
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    yax = nc[source_variable]
    return nc, yax
end

"""
    getForcing(info::NamedTuple)

DOCSTRING
"""
function getForcing(info::NamedTuple)
    nc = nothing
    data_path = info.forcing.default_forcing.data_path
    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
        @info " default_data_path: $(data_path)"
        nc = loadDataFile(data_path)
    end

    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            _, forcing_mask = getYaxFromSource(nothing, mask_path, nothing, "mask", info, Val(Symbol(info.experiment.exe_rules.input_data_backend)))
            forcing_mask = booleanizeMask(forcing_mask)
        end
    end

    default_info = info.forcing.default_forcing
    forcing_variables = keys(info.forcing.variables)
    tar_dims = getTargetDimensionOrder(info)
    @info "getForcing: getting forcing variables..."
    vinfo = nothing
    f_sizes = nothing
    f_dimension = nothing
    num_type = Val{info.tem.helpers.numbers.num_type}()
    incubes = map(forcing_variables) do k
        vinfo = getCombinedVariableInfo(default_info, info.forcing.variables[k])
        data_path_v = getAbsDataPath(info, getfield(vinfo, :data_path))
        nc, yax = getYaxFromSource(nc, data_path, data_path_v, vinfo.source_variable, info, Val(Symbol(info.experiment.exe_rules.input_data_backend)))
        @info "     source_var: $(vinfo.source_variable)"
        incube = subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info, num_type)
        @info "     sindbad_var: $(k)\n "
        if vinfo.space_time_type == "spatiotemporal" && isnothing(f_sizes)
            f_sizes = collectForcingSizes(info, incube)
            f_dimension = getSindbadDims(incube)
        end
        incube
    end
    return getForcingNamedTuple(incubes, f_sizes, f_dimension, info)
end

