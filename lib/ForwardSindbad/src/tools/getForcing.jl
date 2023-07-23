export getForcing, getDimPermutation, loadDataFile
export getYaxFromSource


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

function collectForcingSizes(info, in_yax)
    time_dim_name = Symbol(info.forcing.dimensions.time)
    dnames = Symbol[]
    dsizes = []
    push!(dnames, time_dim_name)
    if time_dim_name in in_yax
        push!(dsizes, length(getproperty(in_yax, time_dim_name)))
    else
        push!(dsizes, length(DimensionalData.lookup(in_yax, time_dim_name)))
    end
    for space ∈ info.forcing.dimensions.space
        push!(dnames, Symbol(space))
        push!(dsizes, length(getproperty(in_yax, Symbol(space))))
    end
    f_sizes = (; Pair.(dnames, dsizes)...)
    return f_sizes
end

function collectForcingInfo(info, f_sizes)
    f_info = (;)
    f_info = setTupleField(f_info, (:dimensions, info.forcing.dimensions))
    if hasproperty(info.forcing, :subset)
        f_info = setTupleField(f_info, (:subset, info.forcing.subset))
    else
        f_info = setTupleField(f_info, (:subset, nothing))
    end
    f_info = setTupleField(f_info, (:sizes, f_sizes))
    new_tem = (info.tem..., forcing=f_info)
    info = setTupleField(info, (:tem, new_tem))
    return info
end

function subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info; clean_data=true, fill_nan=false, yax_qc=nothing, bounds_qc=nothing, num_type=info.tem.helpers.numbers.num_type)

    if !isnothing(forcing_mask)
        yax = yax #todo: mask the forcing variables here depending on the mask of 1 and 0
    end

    if !isnothing(tar_dims)
        permutes = getDimPermutation(YAXArrayBase.dimnames(yax), tar_dims)
        @info "     permuting dimensions to $(tar_dims)..."
        yax = permutedims(yax, permutes)
    end
    if hasproperty(yax, Symbol(info.forcing.dimensions.time))
        init_date = DateTime(info.tem.helpers.dates.start_date)
        last_date = DateTime(info.tem.helpers.dates.end_date) + info.tem.helpers.dates.time_step
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
    if clean_data
        yax = mapCleanData(yax, yax_qc, vfill, bounds_qc, vinfo, Val(num_type))
    else
        yax = map(yax_point -> cleanInvalid(yax_point, vfill), yax)
        yax = num_type.(yax)
    end
    return yax
end

function gettForcingInfo(incubes, f_sizes, f_dimension, vinfo, info)
    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.model_run.mapping.yaxarray))
    @info "getForcing: getting variable name..."
    forcing_variables = keys(info.forcing.variables)
    info = collectForcingInfo(info, f_sizes)
    println("----------------------------------------------")
    forcing = (;
        data=incubes,
        dims=indims,
        dimensions=Sindbad.DataStructures.OrderedDict(f_dimension...),
        variables=forcing_variables,
        sizes=f_sizes)
    return info, forcing
end

function getTargetDimensionOrder(info)
    tar_dims = nothing
    if !isnothing(info.forcing.dimensions.permute)
        tar_dims = Symbol[]
        for pd ∈ info.forcing.dimensions.permute
            tdn = Symbol(pd)
            push!(tar_dims, tdn)
        end
    end
    return tar_dims
end

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

function loadDataFromPath(nc, data_path, data_path_v, source_variable)
    if !isnothing(data_path_v) && (data_path_v !== data_path)
        @info "   data_path: $(data_path_v)"
        nc = loadDataFile(data_path_v)
    elseif isnothing(nc)
        @info " one_data_path: $(data_path)"
        nc = loadDataFile(data_path)
    else
        nc = nc
    end
    @info "     source_var: $(source_variable)"
    return nc
end

function getYaxFromSource(nc, data_path, data_path_v, source_variable, info, ::Val{:netcdf})
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    v = nc[source_variable]
    ax = map(NCDatasets.dimnames(v)) do dn
        rax = nothing
        if dn == info.forcing.dimensions.time
            t = nc[info.forcing.dimensions.time]
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
    yax = YAXArray(Tuple(ax), v)
    return nc, yax
end

function getYaxFromSource(nc, data_path, data_path_v, source_variable, _, ::Val{:zarr})
    nc = loadDataFromPath(nc, data_path, data_path_v, source_variable)
    yax = nc[source_variable]
    return nc, yax
end

function getForcing(info::NamedTuple)
    nc = nothing
    data_path = info.forcing.default_forcing.data_path
    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
    end

    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            _, forcing_mask = getYaxFromSource(nothing, mask_path, nothing, "mask", info, Val(Symbol(info.model_run.rules.input_data_backend)))
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
    incubes = map(forcing_variables) do k
        vinfo = getCombinedVariableInfo(default_info, info.forcing.variables[k])
        data_path_v = getAbsDataPath(info, getfield(vinfo, :data_path))
        nc, yax = getYaxFromSource(nc, data_path, data_path_v, vinfo.source_variable, info, Val(Symbol(info.model_run.rules.input_data_backend)))
        if vinfo.space_time_type == "spatiotemporal"
            f_sizes = collectForcingSizes(info, yax)
            f_dimension = getSindbadDims(yax)
        end
        # incube = yax  
        incube = subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info)
        @info "     sindbad_var: $(k)\n "
        incube
    end
    return gettForcingInfo(incubes, f_sizes, f_dimension, vinfo, info)
end

