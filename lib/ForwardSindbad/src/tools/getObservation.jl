export getObservation



function get_nc_yax_vinfo_bounds(nc, data_path, default_info, v_info, data_sub_field, info; yax=nothing, use_data_sub=true)
    nc_sub = nothing
    yax_sub = nothing
    v_info_sub = nothing
    bounds_sub = nothing
    @info "   $(data_sub_field)"
    if hasproperty(v_info, data_sub_field) && use_data_sub
        v_info_var = getfield(v_info, data_sub_field)
        v_info_sub = getCombinedVariableInfo(default_info, v_info_var)
        data_path_sub = getAbsDataPath(info, v_info_sub.data_path)
        nc_sub = nc
        nc_sub, yax_sub = get_yax_from_source(nc_sub, data_path, data_path_sub, v_info_sub.source_variable, info, Val(Symbol(info.model_run.rules.input_data_backend)))
        bounds_sub = v_info_sub.bounds
    else
        if data_sub_field == :qflag
            @info "     no \"$(data_sub_field)\" field/use_quality_flag=false in optimization settings"
        elseif data_sub_field == :unc
            @info "     no \"$(data_sub_field)\" field/use_uncertainty=false in optimization settings"
        else
            @info "     no \"$(data_sub_field)\" field in optimization settings"
        end
        if !isnothing(yax)
            @info "       assuming values of ones"
            nc_sub = nc
            yax_sub = map(x -> one(x), yax)
            v_info_sub = default_info
            bounds_sub = v_info_sub.bounds
        else
            error("no input yax is provided to set values as ones. Cannot conntinue. Change settings in optimization.json")
        end
    end
    return nc_sub, yax_sub, v_info_sub, bounds_sub
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
    default_info = info.optimization.constraints.default_constraint
    tar_dims = get_target_dimensions(info)

    nc = nothing

    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
        nc = load_data_from_path(nc, data_path, data_path, default_info.source_variable)
    end
    
    varnames = Symbol.(info.optimization.variables_to_constrain)

    yax_mask = nothing
    mask_path = nothing
    if :one_sel_mask ∈ keys(info.optimization.constraints)
        if !isnothing(info.optimization.constraints.one_sel_mask)
            mask_path = getAbsDataPath(info, info.optimization.constraints.one_sel_mask)
            _, yax_mask = get_yax_from_source(nothing, mask_path, nothing, "mask", info, Val(Symbol(info.model_run.rules.input_data_backend)))
            yax_mask = booleanize_mask(yax_mask)
        end
    end
    obscubes = []
    @info "getObservation: getting observation variables..."
    num_type = Val{info.tem.helpers.numbers.num_type}()
    set_numtype = info.tem.helpers.numbers.sNT

    map(varnames) do k
        @info " constraint: $k"

        vinfo = getproperty(info.optimization.constraints.variables, k)

        src_var = vinfo.data.source_variable

        nc, yax, vinfo_data, bounds_data = get_nc_yax_vinfo_bounds(nc, data_path, default_info, vinfo, :data, info)

        # get quality flags data and use it later to mask observations. Set to value of 1 when :qflag field is not given for a data stream or all are turned off by setting info.optimization.constraints.use_quality_flag to false
        nc_qc, yax_qc, vinfo_qc, bounds_qc = get_nc_yax_vinfo_bounds(nc, data_path, default_info, vinfo, :qflag, info; yax=yax, use_data_sub=info.optimization.constraints.use_quality_flag)

        # get uncertainty data and add to observations. Set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.constraints.use_uncertainty to false
        nc_unc, yax_unc, vinfo_unc, bounds_unc = get_nc_yax_vinfo_bounds(nc, data_path, default_info, vinfo, :unc, info; yax=yax, use_data_sub=info.optimization.constraints.use_uncertainty)

        _, yax_mask_v, vinfo_mask, bounds_mask = get_nc_yax_vinfo_bounds(nc, data_path, default_info, vinfo, :sel_mask, info; yax=yax)
        yax_mask_v = booleanize_mask(yax_mask_v)
        if !isnothing(yax_mask)
            yax_mask_v .= yax_mask .* yax_mask_v
        end

        cyax = subset_and_process_yax(yax, yax_mask, tar_dims, vinfo_data, info; fill_nan=true, yax_qc=yax_qc, bounds_qc=bounds_qc)   
        cyax_unc = subset_and_process_yax(yax_unc, yax_mask, tar_dims, vinfo_unc, info;  fill_nan=true, yax_qc=yax_qc, bounds_qc=bounds_qc)   
        yax_mask_v = subset_and_process_yax(yax_mask_v, yax_mask_v, tar_dims, vinfo_mask, info;  clean_data=false)   

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        push!(obscubes, yax_mask_v)
        @info " \n"
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
    return (; data=obscubes, dims=indims, variables=Tuple(varnames_all))
end
