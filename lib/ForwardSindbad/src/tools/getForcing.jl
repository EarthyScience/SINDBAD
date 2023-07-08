export getForcing, getPermutation, subset_space_in_data

"""
    getVariableInfo(default_info, var_info)

combines the property values of the default forcing with the properties set for the particular variable
"""
function getVariableInfo(default_info::NamedTuple, var_info::NamedTuple)
    combined_info = (;)
    default_fields = propertynames(default_info)
    for var_field ∈ default_fields
        if hasproperty(var_info, var_field)
            var_prop = getfield(var_info, var_field)
            # @show var_prop, var_info, var_field
            if !isnothing(var_prop) && length(var_prop) > 0
                combined_info = setTupleField(combined_info,
                    (var_field, getfield(var_info, var_field)))
            end
        else
            combined_info = setTupleField(combined_info,
                (var_field, getfield(default_info, var_field)))
        end
    end
    return combined_info
end

"""
getForcing(info)
"""
function getForcing(info::NamedTuple, ::Val{:table})
    doOnePath = false
    if !isnothing(info.forcing.default_forcing.dataPath)
        doOnePath = true
        if isabspath(info.forcing.default_forcing.dataPath)
            dataPath = info.forcing.default_forcing.dataPath
        else
            dataPath = joinpath(info.experiment_root, info.forcing.default_forcing.dataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []

    default_info = info.forcing.default_forcing
    for v ∈ varnames
        vinfo = getVariableInfo(default_info, getproperty(info.forcing.variables, v))
        if !doOnePath
            dataPath = vinfo.dataPath
            #ds = Dataset(dataPath)
        end
        srcVar = vinfo.sourceVariableName
        ds = NetCDF.ncread(dataPath, srcVar)

        tarVar = Symbol(v)
        ds_dat = ds[:, :, :]
        data_to_push =
            cleanInputData.(ds_dat, Ref(vinfo), info.tem.helpers.numbers.sNT)[1,
                1,
                :]
        if vinfo.spaceTimeType == "spatiotemporal"
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
    dataPath = info.forcing.default_forcing.dataPath
    nc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        @show dataPath
        nc = NetCDF.open(dataPath)
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
        vinfo = getVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            dataPath = getAbsDataPath(info, getfield(vinfo, :dataPath))
            nc = NetCDF.open(dataPath)
        end
        v = nc[vinfo.sourceVariableName]
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
                dt_str = Dates.DateTime(info.tem.helpers.dates.sDate)
                rax = RangeAxis(dn,
                    collect(dt_str:(info.tem.helpers.dates.time_step):(dt_str+Day(length(t) -
                                                                                  1))))
            end
            return rax
        end
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end
        @info "     $(k): source_var: $(vinfo.sourceVariableName), source_file: $(dataPath)"
        yax = YAXArray(ax,
            YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(dataPath,
                vinfo.sourceVariableName,
                size(v)))
        if !isnothing(tar_dims)
            permutes = getPermutation(YAXArrayBase.dimnames(yax), tar_dims)
            @info "             permuting dimensions to $(tar_dims)..."
            yax = permutedims(yax, permutes)
        end
        if hasproperty(yax, Symbol(info.forcing.dimensions.time))
            yax = yax[time=(Date(info.tem.helpers.dates.sDate),
                Date(info.tem.helpers.dates.eDate) + info.tem.helpers.dates.time_step)]
        end

        if hasproperty(info.forcing, :subset)
            yax = subset_space_in_data(info.forcing.subset, yax)
        end

        numtype = Val(info.tem.helpers.numbers.num_type)
        if vinfo.spaceTimeType == "spatiotemporal"
            f_sizes = collect_forcing_sizes(info, yax)
        end
        vfill = 0
        # vfill = mean(v[(.!isnan.(v))])
        return map(v -> cleanInputData(v, vfill, vinfo, numtype), yax)
    end

    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable names..."
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
    dataPath = info.forcing.default_forcing.dataPath
    nc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        @show dataPath
        nc = YAXArrays.open_dataset(zopen(dataPath))
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
        vinfo = getVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            dataPath = getAbsDataPath(info, getfield(vinfo, :dataPath))
            nc = YAXArrays.open_dataset(zopen(dataPath))
        end
        dv = nc[vinfo.sourceVariableName]
        v = YAXArrayBase.yaxconvert(DimArray, dv)
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end

        if hasproperty(info.forcing, :subset)
            v = subset_space_in_data(info.forcing.subset, v)
        end

        @info "     $(k): source_var: $(vinfo.sourceVariableName), source_file: $(dataPath)"
        yax = YAXArrayBase.yaxconvert(YAXArray, Float64.(v))
        if hasproperty(yax, Symbol(info.forcing.dimensions.time))
            yax = yax[time=(Date(info.tem.helpers.dates.sDate),
                Date(info.tem.helpers.dates.eDate) + info.tem.helpers.dates.time_step)]
        end

        if vinfo.spaceTimeType == "spatiotemporal"
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
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = length(incubes[1].time) # look for time instead of using the first yaxarray
    # nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable names..."
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
