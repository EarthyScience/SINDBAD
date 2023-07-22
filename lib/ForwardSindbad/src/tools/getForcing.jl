export getForcing, getPermutation, get_spatial_subset, load_data
export getCombinedVariableInfo, get_yax_from_source

"""
    getCombinedVariableInfo(default_info, var_info)

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


function getPermutation(datDims, permDims)
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

function collect_forcing_sizes(info, in_yax)
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

function collect_forcing_info(info, f_sizes)
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

function get_spatial_subset(ss, v)
    if !isnothing(ss)
        ssname = propertynames(ss)
        for ssn ∈ ssname
            ss_r = getproperty(ss, ssn)
            ss_range = ss_r[1]:ss_r[2]
            if ssn == :site
                v = v[site=ss_range]
            elseif ssn == :latitude
                v = v[latitude=ss_range]
            elseif ssn == :lat
                v = v[lat=ss_range]
            elseif ssn == :longitude
                v = v[longitude=ss_range]
            elseif ssn == :lon
                v = v[site=ss_range]
            elseif ssn == :lon
                v = v[lon=ss_range]
            elseif ssn == :id
                v = v[id=ss_range]
            elseif ssn == :Id
                v = v[Id=ss_range]
            elseif ssn == :ID
                v = v[ID=ss_range]
            else
                error(
                    "subsetting by $(ssn) is not supported. check get_spatial_subset in getForcing.jl"
                )
            end
        end
    end
    return v
end

function subset_and_process_yax(yax, forcing_mask, tar_dims, vinfo, info; clean_data=true, fill_nan=false, yax_qc=nothing, bounds_qc=nothing, num_type = info.tem.helpers.numbers.num_type)

    if !isnothing(forcing_mask)
        yax = yax #todo: mask the forcing variables here depending on the mask of 1 and 0
    end

    if !isnothing(tar_dims)
        permutes = getPermutation(YAXArrayBase.dimnames(yax), tar_dims)
        @info "     permuting dimensions to $(tar_dims)..."
        yax = permutedims(yax, permutes)
    end
    if hasproperty(yax, Symbol(info.forcing.dimensions.time))
        init_date = DateTime(info.tem.helpers.dates.start_date)
        last_date = DateTime(info.tem.helpers.dates.end_date) + info.tem.helpers.dates.time_step
        yax = yax[time=(init_date..last_date)]
    end

    if hasproperty(info.forcing, :subset)
        yax = get_spatial_subset(info.forcing.subset, yax)
    end

    vfill = zero(eltype(yax))
    if fill_nan
        vfill = num_type(NaN)
    end
    if clean_data
        #todo mean of the data instead of zero
        yax = mapCleanData(yax, yax_qc, vfill, bounds_qc, vinfo, Val(num_type))
    else
        yax = map(yax_point -> cleanInvalid(yax_point, vfill), yax)
        yax = num_type.(yax)
    end
    return yax
end

function get_forcing_info(incubes, f_sizes, vinfo, info)
    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.model_run.mapping.yaxarray))
    @info "getForcing: getting variable name..."
    forcing_variables = keys(info.forcing.variables)
    info = collect_forcing_info(info, f_sizes)
    println("----------------------------------------------")
    forcing = (;
        data=incubes,
        dims=indims,
        variables=forcing_variables,
        sizes=f_sizes)

    return info, forcing
end

function get_target_dimensions(info)
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

function load_data(data_path)
    if endswith(data_path, ".nc")
        nc = NCDataset(data_path)
    elseif endswith(data_path, ".zarr")
        nc = YAXArrays.open_dataset(zopen(data_path))
    else
        error("The file ending/data type is not supported for $(datapath). Either use .nc or .zarr file")
    end
    return nc
end

function load_data_from_path(nc, data_path, data_path_v, source_variable)
    if !isnothing(data_path_v) && (data_path_v !== data_path) 
        @info "   data_path: $(data_path_v)"
        nc = load_data(data_path_v)
    elseif isnothing(nc)
        @info " one_data_path: $(data_path)"
        nc = load_data(data_path)
    else
        nc = nc
    end
    @info "     source_var: $(source_variable)"
    return nc
end

function get_yax_from_source(nc, data_path, data_path_v, source_variable, info, ::Val{:netcdf})
    nc = load_data_from_path(nc, data_path, data_path_v, source_variable)
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

function get_yax_from_source(nc, data_path, data_path_v, source_variable, _, ::Val{:zarr})
    nc = load_data_from_path(nc, data_path, data_path_v, source_variable)
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
            _, forcing_mask = get_yax_from_source(nothing, mask_path, nothing, "mask", info, Val(Symbol(info.model_run.rules.input_data_backend)))
            forcing_mask = booleanize_mask(forcing_mask)
        end
    end

    default_info = info.forcing.default_forcing
    forcing_variables = keys(info.forcing.variables)
    tar_dims = get_target_dimensions(info)
    @info "getForcing: getting forcing variables..."
    vinfo = nothing
    f_sizes = nothing
    incubes = map(forcing_variables) do k
        vinfo = getCombinedVariableInfo(default_info, info.forcing.variables[k])
        data_path_v = getAbsDataPath(info, getfield(vinfo, :data_path))
        nc, yax = get_yax_from_source(nc, data_path, data_path_v, vinfo.source_variable, info, Val(Symbol(info.model_run.rules.input_data_backend)))
        if vinfo.space_time_type == "spatiotemporal"
            f_sizes = collect_forcing_sizes(info, yax)
        end
        # incube = yax  
        incube = subset_and_process_yax(yax, forcing_mask, tar_dims, vinfo, info)   
        @info "     sindbad_var: $(k)\n "
        incube
    end
    return get_forcing_info(incubes, f_sizes, vinfo, info)
end

