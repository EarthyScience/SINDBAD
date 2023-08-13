export getForcing

"""
    collectForcingSizes(info, in_yax)


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
    getForcingNamedTuple(incubes, f_sizes, f_dimensions, info)



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
    typed_cubes = getInputArrayOfType(incubes, Val(Symbol(info.experiment.exe_rules.input_array_type)))
    @info "\n----------------------------------------------\n"
    forcing = (;
        data=typed_cubes,
        dims=indims,
        variables=forcing_variables,
        helpers=f_helpers)
    return forcing
end


"""
    getForcing(info::NamedTuple)


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
            _, forcing_mask = getYaxFromSource(nothing, mask_path, nothing, info.forcing.sel_mask_var, info, Val(Symbol(info.experiment.exe_rules.input_data_backend)))
            forcing_mask = booleanizeArray(forcing_mask)
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
        vinfo = getCombinedNamedTuple(default_info, info.forcing.variables[k])
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

