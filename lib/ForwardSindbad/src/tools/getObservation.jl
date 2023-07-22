export getObservation, cleanObsData



function getNCFromPath(data_path::String, ::Val{:netcdf})
    nc_data = load_data(data_path)
    return nc_data
end

function getDataFromPath(data_path::String, srcVar::String, ::Val{:netcdf})
    nc_data = load_data(data_path)
    return nc_data[srcVar]
end

function getNCForMask(mask_path::String)
    nc_mask = load_data(mask_path)
    return nc_mask
end

function getSelObsMask(mask_path::String)
    mask = load_data(mask_path)
    mask_data = mask["mask"]
    return mask_data
end

function getObsZarr(v)
    return YAXArrayBase.yaxconvert(YAXArray, v)
end

function getObsYax(v, nc, info::NamedTuple, variable_name::String, data_path::String)
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
    return yax
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
        vinfo_mask = nothing

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
        data_path_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            vinfo_qc = getCombinedVariableInfo(default_info, vinfo.qflag)
            qc_var = vinfo_qc.source_variable
            data_path_qc = data_path
            if !isnothing(vinfo_qc.data_path)
                data_path_qc = getAbsDataPath(info, vinfo_qc.data_path)
                nc_qc = getNCFromPath(data_path_qc, Val(:netcdf))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo_qc.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(data_path_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.use_uncertainty to false
        data_path_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.optimization.use_uncertainty
            vinfo_unc = getCombinedVariableInfo(default_info, vinfo.unc)
            unc_var = vinfo_unc.source_variable
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            data_path_unc = data_path
            if !isnothing(vinfo_unc.data_path)
                data_path_unc = getAbsDataPath(info, vinfo_unc.data_path)
                nc_unc = YAXArrays.open_dataset(zopen(data_path_unc))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo_unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(data_path_unc)"
        else
            data_path_unc = data_path
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        data_path_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            vinfo_mask = getCombinedVariableInfo(default_info, vinfo.sel_mask)
            data_path_mask = vinfo_mask.data_path
            if !isnothing(data_path_mask)
                nc_mask = YAXArrays.open_dataset(zopen(data_path_mask))
                has_mask = true
            else
                data_path_mask = data_path
                nc_mask = nc
            end
        else
            data_path_mask = data_path
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(data_path_mask)"
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
        cyax = mapCleanObsData(yax, yax_qc,  vinfo_data, bounds, bounds_qc, num_type)
            # cyax = map((da, dq) -> cleanObsData(da, dq, vinfo_data, vinfo_data.bounds, bounds_qc, numtype), yax, yax_qc)
        # cyax = map(da -> cleanObsData(da, vinfo, vinfo_data.bounds, numtype), yax)

        cyax_unc = yax_unc
        if !one_unc
            cyax_unc = mapCleanObsData(yax_unc, yax_qc,  vinfo_data, bounds, bounds_qc, num_type)
            # cyax_unc = map((da, dq) -> cleanObsData(da, dq, vinfo_unc, bounds_unc, bounds_qc, numtype), yax_unc, yax_qc)
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
function getObservation(info::NamedTuple, ::Val{:netcdf})
    forcing_info = info.tem.forcing
    permutes = forcing_info.dimensions.permute
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
        vinfo_mask = nothing

        src_var = vinfo_data.source_variable

        if !doOnePath
            data_path = getAbsDataPath(info, vinfo_data.data_path)
            nc = getNCFromPath(data_path, Val(:netcdf))
        end
        @info "     $(k): Data: source_var: $(src_var), source_file: $(data_path)"
        v = nc[src_var]

        # get the quality flag data
        data_path_qc = nothing
        v_qc = nothing
        nc_qc = nc
        qc_var = nothing
        one_qc = false
        bounds_qc = nothing
        if hasproperty(vinfo, :qflag)
            vinfo_qc = getCombinedVariableInfo(default_info, vinfo.qflag)
            qc_var = vinfo_qc.source_variable
            data_path_qc = data_path
            if !isnothing(vinfo_qc.data_path)
                data_path_qc = getAbsDataPath(info, vinfo_qc.data_path)
                nc_qc = getNCFromPath(data_path_qc, Val(:netcdf))
            else
                nc_qc = nc
            end
            v_qc = nc_qc[qc_var]
            bounds_qc = vinfo_qc.bounds
            @info "          QFlag: source_var: $(qc_var), source_file: $(data_path_qc)"
        else
            @info "          QFlag: No qflag provided. All data points assumed to be the highest quality of 1."
            one_qc = true
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.use_uncertainty to false
        data_path_unc = nothing
        v_unc = nothing
        nc_unc = nc
        unc_var = nothing
        one_unc = false
        bounds_unc = nothing
        if hasproperty(vinfo, :unc) && info.optimization.use_uncertainty
            vinfo_unc = getCombinedVariableInfo(default_info, vinfo.unc)
            unc_var = vinfo_unc.source_variable
            # @info "UNCERTAINTY: Using $(unc_var) as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            data_path_unc = data_path
            if !isnothing(vinfo_unc.data_path)
                data_path_unc = getAbsDataPath(info, vinfo_unc.data_path)
                nc_unc = getNCFromPath(data_path_unc, Val(:netcdf))
            else
                nc_unc = nc
            end
            v_unc = nc_unc[unc_var]
            bounds_unc = vinfo_unc.bounds
            @info "          Unc: source_var: $(unc_var), source_file: $(data_path_unc)"
        else
            data_path_unc = data_path
            @info "          Unc: using ones as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            one_unc = true
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        data_path_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            vinfo_mask = default_info
            if !isnothing(vinfo.sel_mask) 
                vinfo_mask = getCombinedVariableInfo(default_info, vinfo.sel_mask)
            end
            data_path_mask = vinfo_mask.data_path
            if !isnothing(data_path_mask)
                nc_mask = getNCForMask(data_path_mask)
                has_mask = true
            else
                data_path_mask = data_path
                nc_mask = nc
            end
        else
            data_path_mask = data_path
            nc_mask = nc
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        if has_mask
            @info "          Mask: using mask from $(data_path_mask)"
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
            yax_qc = getObsYax(v_qc, nc_qc, info, qc_tar_name, data_path_qc)
        end

        yax_unc = nothing
        if one_unc
            yax_unc = map(x -> one(set_numtype(x)), yax)
        else
            yax_unc = getObsYax(v_unc, nc_unc, info, unc_tar_name, data_path_unc)
        end

        yax_mask = nothing
        if no_mask
            yax_mask = map(x -> Bool(one(x)), yax)
        else
            yax_mask = Bool.(getObsYax(v_mask, nc_mask, info, mask_tar_name, data_path_mask))
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



"""
getObservation(info)
"""
function getObservation(info::NamedTuple)
    forcing_info = nothing
    if hasproperty(info.tem, :forcing)
        forcing_info = info.tem.forcing
    else
        error("info.tem does not include forcing dimensions. To get the observations properly, dimension information from forcing is necessary. Run: 
        
        info, forcing = getForcing(info);
        
        before running getObservation.")
    end
    permutes = forcing_info.dimensions.permute
    data_path = info.optimization.constraints.default_constraint.data_path

    nc = nothing
    nc_qc = nothing
    nc_unc = nothing
    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
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
    num_type = Val{info.tem.helpers.numbers.num_type}()
    set_numtype = info.tem.helpers.numbers.sNT
    tar_dims = get_target_dimensions(info)

    map(varnames) do k
        v = nothing
        vinfo = getproperty(info.optimization.constraints.variables, k)
        vinfo_data = getCombinedVariableInfo(default_info, vinfo.data)

        src_var = vinfo_data.source_variable

        yax = nothing
        yax_qc = nothing
        yax_unc = nothing
        yax_mask = nothing
        
        nc, yax = get_yax_from_source(nc, data_path, vinfo_data, info, Val(Symbol(info.model_run.rules.input_data_backend)))
        # get the quality flag data
        bounds_qc = nothing
        @info "      QFlag:"
        if hasproperty(vinfo, :qflag)
            vinfo_qc = getCombinedVariableInfo(default_info, vinfo.qflag)
            data_path_qc = data_path
            nc_qc = nothing
            if !isnothing(vinfo_qc.data_path) && (data_path_qc == vinfo_qc.data_path)
                nc_qc = nc
            end
            nc_qc, yax_qc = get_yax_from_source(nc_qc, data_path_qc, vinfo_qc, info, Val(Symbol(info.model_run.rules.input_data_backend)))
            bounds_qc = vinfo_qc.bounds
        else
            @info "          No qflag provided. All data points assumed to be the highest quality of 1."
            yax_qc = map(x -> one(x), yax)
        end

        # get uncertainty data and add to observations. For all cases, uncertainties are used, but set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.use_uncertainty to false
        vinfo_unc = vinfo_data
        @info "      Unc:"
        if hasproperty(vinfo, :unc) && info.optimization.use_uncertainty
            vinfo_unc = getCombinedVariableInfo(default_info, vinfo.unc)
            nc_unc = nothing
            if !isnothing(vinfo_unc.data_path) && (data_path_unc == vinfo_unc.data_path)
                nc_unc = nc
            end
            nc_unc, yax_unc = get_yax_from_source(nc_unc, data_path_unc, vinfo_unc, info, Val(Symbol(info.model_run.rules.input_data_backend)))
        else
            @info "         using ones as uncertainty in optimization for $(k) => info.optimization.use_uncertainty is set as $(info.optimization.use_uncertainty)"
            yax_unc = map(x -> one(x), yax)
        end

        # get the mask to apply to data and save to observation cube
        has_mask = false
        vinfo_mask = nothing
        data_path_mask = mask_path
        if hasproperty(vinfo, :sel_mask)
            vinfo_mask = default_info
            if !isnothing(vinfo_mask.data_path)
                nc_unc, yax_unc = get_yax_from_source(nc_unc, doOnePath, data_path_unc, vinfo_unc, info, Val(Symbol(info.model_run.rules.input_data_backend)))
            else
                nc_unc = nc
                yax_unc = yax
            end

            if !isnothing(vinfo.sel_mask) 
                vinfo_mask = getCombinedVariableInfo(default_info, vinfo.sel_mask)
            end
            data_path_mask = vinfo_mask.data_path
            if !isnothing(data_path_mask)
                nc_mask, yax_mask = get_yax_from_source(nc_mask, doOnePath, data_path_mask, vinfo_mask, info, Val(Symbol(info.model_run.rules.input_data_backend)))
                has_mask = true
            else
                data_path_mask = data_path
                nc_mask = nc
                yax_mask = yax
            end
        else
            data_path_mask = data_path
            nc_mask = nc
            yax_mask = yax
        end

        v_mask = nothing
        maskvar = "mask"
        no_mask = false
        @info "      Mask:"
        if has_mask
            @info "       using mask from $(data_path_mask)"
        else
            @info "       selecting locations of all available data points as the mask for $(k) => one_sel_mask and sel_mask are either non-existent or set as null in json"
            no_mask = true
        end
        cyax = subset_and_process_yax(yax, yax_mask, tar_dims, vinfo_data, info; fill_nan=true, yax_qc=yax_qc, bounds_qc=bounds_qc)   
        cyax_unc = subset_and_process_yax(yax, yax_mask, tar_dims, vinfo_unc, info;  fill_nan=true, yax_qc=yax_qc, bounds_qc=bounds_qc)   
        yax_mask = subset_and_process_yax(yax_mask, yax_mask, tar_dims, vinfo_mask, info;  clean_data=false, num_type=Bool)   

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
