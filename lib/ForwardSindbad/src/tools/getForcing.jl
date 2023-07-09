export getForcing, getPermutation, subset_space_in_data
export getCombinedVariableInfo

"""
    getCombinedVariableInfo(default_info, var_info)

combines the property values of the default forcing with the properties set for the particular variable
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
            # @show var_prop, var_info, var_field
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
getForcing(info)
"""
function getForcing(info::NamedTuple, ::Val{:table})
    doOnePath = false
    if !isnothing(info.forcing.default_forcing.data_path)
        doOnePath = true
        if isabspath(info.forcing.default_forcing.data_path)
            data_path = info.forcing.default_forcing.data_path
        else
            data_path = joinpath(info.experiment_root, info.forcing.default_forcing.data_path)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []

    default_info = info.forcing.default_forcing
    for v ∈ varnames
        vinfo = getCombinedVariableInfo(default_info, getproperty(info.forcing.variables, v))
        if !doOnePath
            data_path = vinfo.data_path
            #ds = Dataset(data_path)
        end
        srcVar = vinfo.source_variable_name
        ds = NetCDF.ncread(data_path, srcVar)

        tarVar = Symbol(v)
        ds_dat = ds[:, :, :]
        data_to_push =
            cleanInputData.(ds_dat, Ref(vinfo), info.tem.helpers.numbers.sNT)[1,
                1,
                :]
        if vinfo.space_time_type == "spatiotemporal"
            push!(varlist, tarVar)
            push!(dataAr, data_to_push)
        else
            push!(varlist, tarVar)
            push!(dataAr, fill(data_to_push, info.forcing.size.time))
        end
    end
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end

function get_forcing_sel_mask(mask_path::String)
    mask = NetCDF.open(mask_path)
    mask_data = mask["mask"]
    return mask_data
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
    dnames = Symbol[]
    dsizes = Int64[]
    push!(dnames, Symbol(info.forcing.dimensions.time))
    push!(dsizes, length(getproperty(in_yax, Symbol(info.forcing.dimensions.time))))
    for space ∈ info.forcing.dimensions.space
        push!(dnames, Symbol(space))
        push!(dsizes, length(getproperty(in_yax, Symbol(space))))
    end
    f_sizes = (; Pair.(dnames, dsizes)...)
    return f_sizes
end

function collect_forcing_info(info, f_sizes, permutes)
    f_info = (;)
    f_info = setTupleField(f_info, (:dimensions, info.forcing.dimensions))
    if hasproperty(info.forcing, :subset)
        f_info = setTupleField(f_info, (:subset, info.forcing.subset))
    else
        f_info = setTupleField(f_info, (:subset, nothing))
    end
    f_info = setTupleField(f_info, (:sizes, f_sizes))
    f_info = setTupleField(f_info, (:permutes, permutes))
    new_tem = (info.tem..., forcing=f_info)
    info = setTupleField(info, (:tem, new_tem))
    return info
end

function subset_space_in_data(ss, v)
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
                    "subsetting by $(ssn) is not supported. check subset_space_in_data in getForcing.jl"
                )
            end
        end
    end
    return v
end

function getForcing(info::NamedTuple, ::Val{:yaxarray})
    doOnePath = false
    data_path = info.forcing.default_forcing.data_path
    nc = Any
    if !isnothing(data_path)
        doOnePath = true
        data_path = getAbsDataPath(info, data_path)
        @show data_path
        nc = NetCDF.open(data_path)
    end
    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            forcing_mask = get_forcing_sel_mask(mask_path)
        end
    end

    default_info = info.forcing.default_forcing
    forcing_variables = keys(info.forcing.variables)
    tar_dims = nothing
    permutes = nothing
    f_sizes = nothing
    if !isnothing(info.forcing.dimensions.permute)
        tar_dims = Symbol[]
        for pd ∈ info.forcing.dimensions.permute
            tdn = Symbol(pd)
            push!(tar_dims, tdn)
        end
    end
    @info "getForcing: getting forcing variables..."
    incubes = map(forcing_variables) do k
        vinfo = getCombinedVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            data_path = getAbsDataPath(info, getfield(vinfo, :data_path))
            nc = NetCDF.open(data_path)
        end
        v = nc[vinfo.source_variable_name]
        atts = v.atts
        if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
            v = CFDiskArray(v, atts)
        end
        ax = map(v.dim) do d
            dn = d.name
            if dn in keys(nc)
                dv = nc[dn][:]
            else
                error("cannot run sindbad when the dimension variable $(dn) is not available in data")
            end
            rax = RangeAxis(dn, dv)
            if dn == info.forcing.dimensions.time
                t = nc[info.forcing.dimensions.time]
                dt_str = Dates.DateTime(info.tem.helpers.dates.start_date)
                rax = RangeAxis(dn,
                    collect(dt_str:(info.tem.helpers.dates.time_step):(dt_str+Day(length(t) -
                                                                                  1))))
            end
            return rax
        end
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end
        @info "     $(k): source_var: $(vinfo.source_variable_name), source_file: $(data_path)"
        yax = YAXArray(ax,
            YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(data_path,
                vinfo.source_variable_name,
                size(v)))
        if !isnothing(tar_dims)
            permutes = getPermutation(YAXArrayBase.dimnames(yax), tar_dims)
            @info "             permuting dimensions to $(tar_dims)..."
            yax = permutedims(yax, permutes)
        end
        if hasproperty(yax, Symbol(info.forcing.dimensions.time))
            yax = yax[time=(Date(info.tem.helpers.dates.start_date),
                Date(info.tem.helpers.dates.end_date) + info.tem.helpers.dates.time_step)]
        end

        if hasproperty(info.forcing, :subset)
            yax = subset_space_in_data(info.forcing.subset, yax)
        end

        numtype = Val(info.tem.helpers.numbers.num_type)
        if vinfo.space_time_type == "spatiotemporal"
            f_sizes = collect_forcing_sizes(info, yax)
        end
        vfill = 0
        # vfill = mean(v[(.!isnan.(v))])
        return map(v -> cleanInputData(v, vfill, vinfo, numtype), yax)
    end

    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.model_run.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable name..."
    forcing_variables = keys(info.forcing.variables)
    info = collect_forcing_info(info, f_sizes, permutes)
    println("----------------------------------------------")
    forcing = (;
        data=incubes,
        dims=indims,
        n_timesteps=nts,
        variables=forcing_variables,
        sizes=f_sizes)
    return info, forcing
end

function getForcing(info::NamedTuple, ::Val{:zarr})
    doOnePath = false
    data_path = info.forcing.default_forcing.data_path
    nc = Any
    if !isnothing(data_path)
        doOnePath = true
        data_path = getAbsDataPath(info, data_path)
        @show data_path
        nc = YAXArrays.open_dataset(zopen(data_path))
    end

    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            forcing_mask = get_forcing_sel_mask(mask_path)
        end
    end

    default_info = info.forcing.default_forcing
    forcing_variables = keys(info.forcing.variables)
    tar_dims = nothing
    permutes = nothing
    f_sizes = nothing
    if !isnothing(info.forcing.dimensions.permute)
        tar_dims = Symbol[]
        for pd ∈ info.forcing.dimensions.permute
            tdn = Symbol(getfield(info.forcing.dimensions, Symbol(pd)))
            push!(tar_dims, tdn)
        end
    end
    @info "getForcing: getting forcing variables..."
    incubes = map(forcing_variables) do k
        vinfo = getCombinedVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            data_path = getAbsDataPath(info, getfield(vinfo, :data_path))
            nc = YAXArrays.open_dataset(zopen(data_path))
        end
        dv = nc[vinfo.source_variable_name]
        v = YAXArrayBase.yaxconvert(DimArray, dv)
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end

        if hasproperty(info.forcing, :subset)
            v = subset_space_in_data(info.forcing.subset, v)
        end

        @info "     $(k): source_var: $(vinfo.source_variable_name), source_file: $(data_path)"
        yax = YAXArrayBase.yaxconvert(YAXArray, Float64.(v))
        if hasproperty(yax, Symbol(info.forcing.dimensions.time))
            yax = yax[time=(Date(info.tem.helpers.dates.start_date),
                Date(info.tem.helpers.dates.end_date) + info.tem.helpers.dates.time_step)]
        end

        if vinfo.space_time_type == "spatiotemporal"
            f_sizes = collect_forcing_sizes(info, yax)
        end

        @info "getForcing: checking if permutation of data is needed..."
        if !isnothing(tar_dims)
            permutes = getPermutation(YAXArrayBase.dimnames(yax), tar_dims)
            @info "permuting dimensions to $(tar_dims)..."
            yax = permutedims(yax, permutes)
        end
        numtype = info.tem.helpers.numbers.sNT
        numtype = Val(info.tem.helpers.numbers.num_type)
        vfill = 0
        # vfill = mean(v[(.!isnan.(v))])
        return map(v -> cleanInputData(v, vfill, vinfo, numtype), yax)
    end
    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.model_run.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = length(incubes[1].time) # look for time instead of using the first yaxarray
    # nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable name..."
    forcing_variables = keys(info.forcing.variables)
    info = collect_forcing_info(info, f_sizes, permutes)
    println("----------------------------------------------")
    forcing = (;
        data=incubes,
        dims=indims,
        n_timesteps=nts,
        variables=forcing_variables,
        sizes=f_sizes)
    return info, forcing
end
