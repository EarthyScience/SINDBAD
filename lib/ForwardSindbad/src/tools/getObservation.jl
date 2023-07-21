export getObservation, cleanObsData


function cleanObsData(datapoint, datapoint_qc, vinfo_data, bounds, bounds_qc, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint,
        vinfo_data.source_to_sindbad_unit,
        vinfo_data.additive_unit_conversion)
    if !isnothing(bounds)
        if datapoint < first(bounds) || datapoint > last(bounds)
            datapoint = T(NaN)
        end
    end
    if !isnothing(bounds_qc)
        if datapoint_qc < first(bounds_qc) || datapoint_qc > last(bounds_qc)
            datapoint = T(NaN)
        end
    end
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

function getDataFromPath(data_path::String, srcVar::String)
    ds = NetCDF.ncread(data_path, srcVar)
    data_tmp = ds[1, 1, :] # TODO multidimensional input
    return data_tmp
end

function getNCFromPath(data_path::String, ::Val{:yaxarray})
    nc_data = NetCDF.open(data_path)
    return nc_data
end

function getDataFromPath(data_path::String, srcVar::String, ::Val{:yaxarray})
    nc_data = NetCDF.open(data_path)
    return nc_data[srcVar]
end

function getNCForMask(mask_path::String)
    nc_mask = NetCDF.open(mask_path)
    return nc_mask
end

function getSelObsMask(mask_path::String)
    mask = NetCDF.open(mask_path)
    mask_data = mask["mask"]
    return mask_data
end

function getObsZarr(v)
    return YAXArrayBase.yaxconvert(YAXArray, v)
end

function getObsYax(v, nc, info::NamedTuple, variable_name::String, data_path::String)
    atts = v.atts
    if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
        v = CFDiskArray(v, atts)
    end
    ax = map(v.dim) do d
        dn = d.name
        if dn in keys(nc)
            dv = nc[dn][:]
        else
            # @show v, size(v)
            dv = 1:size(v, 2)
        end
        rax = RangeAxis(dn, dv)
        if dn == info.tem.forcing.dimensions.time
            t = nc[info.tem.forcing.dimensions.time]
            dt_str = Dates.DateTime(join(split(t.atts["units"], " ")[3:end], "T"))
            rax = RangeAxis(dn, collect(dt_str:Day(1):(dt_str+Day(length(t) - 1))))
        end
        rax
    end
    # yax = YAXArray(ax, v)
    yax = YAXArray(ax,
        YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(data_path, variable_name,
            size(v)))
    return yax
end

function time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info, forcing_info)
    if hasproperty(cyax, Symbol(forcing_info.dimensions.time))
        cyax = cyax[time=(Date(info.tem.helpers.dates.start_date),
            Date(info.tem.helpers.dates.end_date) + info.tem.helpers.dates.time_step)]
    end
    if hasproperty(cyax_unc, Symbol(forcing_info.dimensions.time))
        cyax_unc = cyax_unc[time=(Date(info.tem.helpers.dates.start_date),
            Date(info.tem.helpers.dates.end_date) +
            info.tem.helpers.dates.time_step)]
    end
    if hasproperty(yax_mask, Symbol(forcing_info.dimensions.time))
        yax_mask = yax_mask[time=(Date(info.tem.helpers.dates.start_date),
            Date(info.tem.helpers.dates.end_date) +
            info.tem.helpers.dates.time_step)]
    end
    return cyax, cyax_unc, yax_mask
end

"""
getObservation(info)
"""
function getObservation(info::NamedTuple, ::Val{:zarr})
    forcing_info = info.tem.forcing
    permutes = forcing_info.permutes
    subset = forcing_info.subset
    doOnePath = false
    data_path = info.optimization.constraints.default_constraint.data_path
    nc = nothing
    nc_qc = nothing
    nc_unc = nothing
    if !isnothing(data_path)
        doOnePath = true
        data_path = getAbsDataPath(info, data_path)
        nc = YAXArrays.open_dataset(zopen(data_path))
    end
    varnames = Symbol.(info.optimization.variables_to_constrain)
    nc_mask = nothing
    mask_path = nothing
    if :one_sel_mask ∈ keys(info.optimization.constraints)
        if !isnothing(info.optimization.constraints.one_sel_mask)
            mask_path = getAbsDataPath(info, info.optimization.constraints.one_sel_mask)
            nc_mask = getNCForMask(mask_path)
        end
    end
    obscubes = []
    @info "getObservation: getting observation variables..."
    default_info = info.optimization.constraints.default_constraint
    numtype = Val{info.tem.helpers.numbers.num_type}()
    set_numtype = info.tem.helpers.numbers.sNT
    map(varnames) do k
        v = nothing
        vinfo = getproperty(info.optimization.constraints.variables, k)
        vinfo_data = getCombinedVariableInfo(default_info, vinfo.data)
        vinfo_unc = nothing
        vinfo_qc = nothing
        vinfo_sel_mask = nothing

        src_var = vinfo_data.source_variable

        if !doOnePath
            data_path = getAbsDataPath(info, vinfo_data.data_path)
            nc = YAXArrays.open_dataset(zopen(data_path))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(data_path)"
        ov = nc[src_var]
        v = YAXArrayBase.yaxconvert(DimArray, ov)
        # site, lon, lat should be options to consider here
        # v = v[site=1:forcing_info.size.site, time = 1:forcing_info.size.time]

        # get the quality flag data
        dataPath_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            vinfo_qc = getCombinedVariableInfo(default_info, vinfo.qflag)
            qc_var = vinfo_qc.source_variable
            dataPath_qc = data_path
            if !isnothing(vinfo_qc.data_path)
                dataPath_qc = getAbsDataPath(info, vinfo_qc.data_path)
                nc_qc = getNCFromPath(dataPath_qc, Val(:yaxarray))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo_qc.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(dataPath_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.use_uncertainty to false
        dataPath_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.optimization.use_uncertainty
            vinfo_unc = getCombinedVariableInfo(default_info, vinfo.unc)
            unc_var = vinfo_unc.source_variable
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            dataPath_unc = data_path
            if !isnothing(vinfo_unc.data_path)
                dataPath_unc = getAbsDataPath(info, vinfo_unc.data_path)
                nc_unc = YAXArrays.open_dataset(zopen(dataPath_unc))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo_unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(dataPath_unc)"
        else
            dataPath_unc = data_path
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        dataPath_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            vinfo_sel_mask = getCombinedVariableInfo(default_info, vinfo.sel_mask)
            dataPath_mask = vinfo_sel_mask.data_path
            if !isnothing(dataPath_mask)
                nc_mask = YAXArrays.open_dataset(zopen(dataPath_mask))
                has_mask = true
            else
                dataPath_mask = data_path
                nc_mask = nc
            end
        else
            dataPath_mask = data_path
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(dataPath_mask)"
            v_mask = nc_mask[maskvar]
        else
            @info "          Mask: selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are either non-existent or set as null in json"
            no_mask = true
        end
        unc_tar_name = string(unc_var)
        qc_tar_name = string(qc_var)
        mask_tar_name = string(src_var)
        if !isnothing(subset)
            v = subset_space_in_data(subset, v)
        end

        yax = getObsZarr(v)

        yax_qc = nothing
        if one_qc
            yax_qc = map(x -> one(set_numtype(x)), yax)
        else
            yax_qc = getObsZarr(v_qc)
        end

        yax_unc = nothing
        if one_unc
            yax_unc = map(x -> one(set_numtype(x)), yax)
        else
            yax_unc = getObsZarr(v_unc)
        end

        yax_mask = nothing
        if no_mask
            yax_mask = map(x -> Bool(one(x)), yax)
        else
            yax_mask = Bool.(getObsZarr(v_mask))
        end


        # clean the data by applying bounds
        cyax = map((da, dq) -> cleanObsData(da, dq, vinfo_data, vinfo_data.bounds, bounds_qc, numtype), yax, yax_qc)
        # cyax = map(da -> cleanObsData(da, vinfo, vinfo_data.bounds, numtype), yax)

        cyax_unc = yax_unc
        if !one_unc
            cyax_unc = map((da, dq) -> cleanObsData(da, dq, vinfo_unc, bounds_unc, bounds_qc, numtype), yax_unc, yax_qc)
            # cyax_unc = map(da -> cleanObsData(da, vinfo, vinfo_unc.bounds, numtype), yax_unc)
        end
        if !isnothing(permutes)
            @info "permuting dimensions to $(tar_dims)..."
            cyax = permutedims(cyax, permutes)
            cyax_unc = permutedims(cyax_unc, permutes)
            yax_mask = permutedims(yax_mask, permutes)
        end

        cyax, cyax_unc, yax_mask = time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info,
            forcing_info)

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        push!(obscubes, yax_mask)
    end
    @info "getObservation: getting observation dimensions..."
    indims = getDataDims.(obscubes, Ref(info.model_run.mapping.yaxarray))
    @info "getObservation: getting number of time steps..."
    nts = getNumberOfTimeSteps(obscubes, forcing_info.dimensions.time)
    @info "getObservation: getting variable name..."
    varnames_all = []
    for v ∈ varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
    end
    println("----------------------------------------------")
    return (; data=obscubes, dims=indims, n_timesteps=nts, variables=varnames_all)
end

"""
getObservation(info)
"""
function getObservation(info::NamedTuple, ::Val{:yaxarray})
    forcing_info = info.tem.forcing
    permutes = forcing_info.permutes
    doOnePath = false
    data_path = info.optimization.constraints.default_constraint.data_path
    nc = nothing
    nc_qc = nothing
    nc_unc = nothing
    if !isnothing(data_path)
        doOnePath = true
        data_path = getAbsDataPath(info, data_path)
        nc = NetCDF.open(data_path)
    end
    varnames = Symbol.(info.optimization.variables_to_constrain)
    nc_mask = nothing
    mask_path = nothing
    if :one_sel_mask ∈ keys(info.optimization.constraints)
        if !isnothing(info.optimization.constraints.one_sel_mask)
            mask_path = getAbsDataPath(info, info.optimization.constraints.one_sel_mask)
            nc_mask = getNCForMask(mask_path)
        end
    end
    obscubes = []
    @info "getObservation: getting observation variables..."
    default_info = info.optimization.constraints.default_constraint
    numtype = Val{info.tem.helpers.numbers.num_type}()
    set_numtype = info.tem.helpers.numbers.sNT
    map(varnames) do k
        v = nothing
        vinfo = getproperty(info.optimization.constraints.variables, k)
        vinfo_data = getCombinedVariableInfo(default_info, vinfo.data)
        vinfo_unc = nothing
        vinfo_qc = nothing
        vinfo_sel_mask = nothing

        src_var = vinfo_data.source_variable

        if !doOnePath
            data_path = getAbsDataPath(info, vinfo_data.data_path)
            nc = getNCFromPath(data_path, Val(:yaxarray))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(data_path)"
        v = nc[src_var]

        # get the quality flag data
        dataPath_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            vinfo_qc = getCombinedVariableInfo(default_info, vinfo.qflag)
            qc_var = vinfo_qc.source_variable
            dataPath_qc = data_path
            if !isnothing(vinfo_qc.data_path)
                dataPath_qc = getAbsDataPath(info, vinfo_qc.data_path)
                nc_qc = getNCFromPath(dataPath_qc, Val(:yaxarray))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo_qc.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(dataPath_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.use_uncertainty to false
        dataPath_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.optimization.use_uncertainty
            vinfo_unc = getCombinedVariableInfo(default_info, vinfo.unc)
            unc_var = vinfo_unc.source_variable
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            dataPath_unc = data_path
            if !isnothing(vinfo_unc.data_path)
                dataPath_unc = getAbsDataPath(info, vinfo_unc.data_path)
                nc_unc = getNCFromPath(dataPath_unc, Val(:yaxarray))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo_unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(dataPath_unc)"
        else
            dataPath_unc = data_path
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        dataPath_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            vinfo_sel_mask = default_info
            if !isnothing(vinfo.sel_mask) 
                vinfo_sel_mask = getCombinedVariableInfo(default_info, vinfo.sel_mask)
            end
            dataPath_mask = vinfo_sel_mask.data_path
            if !isnothing(dataPath_mask)
                nc_mask = getNCForMask(dataPath_mask)
                has_mask = true
            else
                dataPath_mask = data_path
                nc_mask = nc
            end
        else
            dataPath_mask = data_path
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(dataPath_mask)"
            v_mask = nc_mask[maskvar]
        else
            @info "          Mask: selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are either non-existent or set as null in json"
            no_mask = true
        end
        unc_tar_name = string(unc_var)
        qc_tar_name = string(qc_var)
        mask_tar_name = string(src_var)

        yax = getObsYax(v, nc, info, src_var, data_path)

        yax_qc = nothing
        if one_qc
            yax_qc = map(x -> one(set_numtype(x)), yax)
        else
            yax_qc = getObsYax(v_qc, nc_qc, info, qc_tar_name, dataPath_qc)
        end

        yax_unc = nothing
        if one_unc
            yax_unc = map(x -> one(set_numtype(x)), yax)
        else
            yax_unc = getObsYax(v_unc, nc_unc, info, unc_tar_name, dataPath_unc)
        end

        yax_mask = nothing
        if no_mask
            yax_mask = map(x -> Bool(one(x)), yax)
        else
            yax_mask = Bool.(getObsYax(v_mask, nc_mask, info, mask_tar_name, dataPath_mask))
        end


        # clean the data by applying bounds
        cyax = map((da, dq) -> cleanObsData(da, dq, vinfo_data, vinfo_data.bounds, bounds_qc, numtype), yax, yax_qc)
        # cyax = map(da -> cleanObsData(da, vinfo, vinfo_data.bounds, numtype), yax)

        cyax_unc = yax_unc
        if !one_unc
            cyax_unc = map((da, dq) -> cleanObsData(da, dq, vinfo_unc, bounds_unc, bounds_qc, numtype), yax_unc, yax_qc)
            # cyax_unc = map(da -> cleanObsData(da, vinfo, bounds_unc, numtype), yax_unc)
        end
        if !isnothing(permutes)
            @info "         permuting dimensions ..."
            cyax = permutedims(cyax, permutes)
            cyax_unc = permutedims(cyax_unc, permutes)
            yax_mask = permutedims(yax_mask, permutes)
        end

        cyax, cyax_unc, yax_mask = time_slice_yax_cubes(cyax, cyax_unc, yax_mask, info,
            forcing_info)

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        push!(obscubes, yax_mask)
    end
    @info "getObservation: getting observation dimensions..."
    indims = getDataDims.(obscubes, Ref(info.model_run.mapping.yaxarray))
    @info "getObservation: getting number of time steps..."
    nts = forcing_info.sizes
    @info "getObservation: getting variable name..."
    varnames_all = []
    for v ∈ varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
    end
    println("----------------------------------------------")
    return (; data=obscubes, dims=indims, n_timesteps=nts, variables=varnames_all)
end
