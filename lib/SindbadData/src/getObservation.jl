export getObservation

"""
    getAllConstraintData(nc, data_backend, data_path, default_info, v_info, data_sub_field, info; yax = nothing, use_data_sub = true)



# Arguments:
- `nc`: DESCRIPTION
- `data_path`: DESCRIPTION
- `default_info`: DESCRIPTION
- `v_info`: DESCRIPTION
- `data_sub_field`: DESCRIPTION
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `yax`: DESCRIPTION
- `use_data_sub`: DESCRIPTION
"""
function getAllConstraintData(nc, data_backend, data_path, default_info, v_info, data_sub_field, info; yax=nothing, use_data_sub=true)
    nc_sub = nothing
    yax_sub = nothing
    v_info_sub = nothing
    bounds_sub = nothing
    @info "   $(data_sub_field)"
    get_it_from_path = false
    if hasproperty(v_info, data_sub_field) && use_data_sub
        get_it_from_path = true
        v_info_var = getfield(v_info, data_sub_field)
        if isnothing(v_info_var)
            get_it_from_path = false
        end
    end
    if get_it_from_path
        v_info_var = getfield(v_info, data_sub_field)
        v_info_sub = getCombinedNamedTuple(default_info, v_info_var)
        data_path_sub = getAbsDataPath(info, v_info_sub.data_path)
        nc_sub = nc
        nc_sub, yax_sub = getYaxFromSource(nc_sub, data_path, data_path_sub, v_info_sub.source_variable, info, data_backend)
        bounds_sub = v_info_sub.bounds
    else
        if data_sub_field == :qflag
            @info "     no \"$(data_sub_field)\" field OR use_quality_flag=false in optimization settings"
        elseif data_sub_field == :unc
            @info "     no \"$(data_sub_field)\" field OR use_uncertainty=false in optimization settings"
        elseif data_sub_field == :weight
            @info "     no \"$(data_sub_field)\" field OR use_spatial_weight=false in optimization settings"
        else
            @info "     no \"$(data_sub_field)\" field OR sel_mask=null in optimization settings"
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
getObservation(info, forcing.helpers)
"""

"""
    getObservation(info::NamedTuple, forcing_helpers::NamedTuple)


"""
function getObservation(info::NamedTuple, forcing_helpers::NamedTuple)
    data_path = info.optimization.observations.default_observation.data_path
    data_backend = getfield(SindbadData, toUpperCaseFirst(info.experiment.exe_rules.input_data_backend, "Backend"))()
    default_info = info.optimization.observations.default_observation
    tar_dims = getTargetDimensionOrder(info)

    nc = nothing

    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
        @info "getObservation:  default_observation_data_path: $(data_path)"
        nc = loadDataFile(data_path)
    end

    varnames = Symbol.(info.optimization.observational_constraints)

    yax_mask = nothing
    if :one_sel_mask ∈ keys(info.optimization.observations)
        if !isnothing(info.optimization.observations.one_sel_mask)
            mask_path = getAbsDataPath(info, info.optimization.observations.one_sel_mask)
            _, yax_mask = getYaxFromSource(nothing, mask_path, nothing, "mask", info, data_backend)
            yax_mask = booleanizeArray(yax_mask)
        end
    end
    obscubes = []
    num_type = Val{info.tem.helpers.numbers.num_type}()
    num_type_bool = Val{Bool}()

    @info "getObservation: getting observation variables..."
    map(varnames) do k
        @info " constraint: $k"

        vinfo = getproperty(info.optimization.observations.variables, k)

        src_var = vinfo.data.source_variable

        nc, yax, vinfo_data, bounds_data = getAllConstraintData(nc, data_backend, data_path, default_info, vinfo, :data, info)

        # get quality flags data and use it later to mask observations. Set to value of 1 when :qflag field is not given for a data stream or all are turned off by setting info.optimization.observations.use_quality_flag to false
        nc_qc, yax_qc, vinfo_qc, bounds_qc = getAllConstraintData(nc, data_backend, data_path, default_info, vinfo, :qflag, info; yax=yax, use_data_sub=info.optimization.observations.use_quality_flag)

        # get uncertainty data and add to observations. Set to value of 1 when :unc field is not given for a data stream or all are turned off by setting info.optimization.observations.use_uncertainty to false
        nc_unc, yax_unc, vinfo_unc, bounds_unc = getAllConstraintData(nc, data_backend, data_path, default_info, vinfo, :unc, info; yax=yax, use_data_sub=info.optimization.observations.use_uncertainty)

        nc_wgt, yax_wgt, vinfo_wgt, bounds_wgt = getAllConstraintData(nc, data_backend, data_path, default_info, vinfo, :weight, info; yax=yax, use_data_sub=info.optimization.observations.use_spatial_weight)

        _, yax_mask_v, vinfo_mask, bounds_mask = getAllConstraintData(nc, data_backend, data_path, default_info, vinfo, :sel_mask, info; yax=yax)
        yax_mask_v = booleanizeArray(yax_mask_v)
        if !isnothing(yax_mask)
            yax_mask_v .= yax_mask .* yax_mask_v
        end
        @info "   harmonizing qflag"
        cyax_qc = subsetAndProcessYax(yax_qc, yax_mask_v, tar_dims, vinfo_qc, info, num_type; clean_data=false)
        @info "   harmonizing data"
        cyax = subsetAndProcessYax(yax, yax_mask, tar_dims, vinfo_data, info, num_type; fill_nan=true, yax_qc=cyax_qc, bounds_qc=bounds_qc)
        @info "   harmonizing unc"
        cyax_unc = subsetAndProcessYax(yax_unc, yax_mask, tar_dims, vinfo_unc, info, num_type; fill_nan=true, yax_qc=cyax_qc, bounds_qc=bounds_qc)
        @info "   harmonizing weight"
        cyax_wgt = subsetAndProcessYax(yax_wgt, yax_mask, tar_dims, vinfo_wgt, info, num_type; fill_nan=true, yax_qc=cyax_qc, bounds_qc=bounds_qc)
        @info "   harmonizing mask"
        yax_mask_v = subsetAndProcessYax(yax_mask_v, yax_mask_v, tar_dims, vinfo_mask, info, num_type_bool; clean_data=false)

        push!(obscubes, cyax)
        push!(obscubes, cyax_unc)
        push!(obscubes, yax_mask_v)
        push!(obscubes, cyax_wgt)
        @info " \n"
    end
    @info "getObservation: getting observation dimensions..."
    indims = getDataDims.(obscubes, Ref(info.forcing.data_dimension.space))
    @info "getObservation: getting number of time steps..."
    nts = forcing_helpers.sizes
    @info "getObservation: getting variable name..."
    varnames_all = []
    for v ∈ varnames
        push!(varnames_all, v)
        push!(varnames_all, Symbol(string(v) * "_σ"))
        push!(varnames_all, Symbol(string(v) * "_mask"))
        push!(varnames_all, Symbol(string(v) * "_weight"))
    end
    input_array_type = getfield(SindbadData, toUpperCaseFirst(info.experiment.exe_rules.input_array_type, "Input"))()
    @info "\n----------------------------------------------\n"
    return (; data=getInputArrayOfType(obscubes, input_array_type), dims=indims, variables=Tuple(varnames_all))
end
