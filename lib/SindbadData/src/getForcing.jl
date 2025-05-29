export getForcing

"""
    collectForcingSizes(info, in_yax)

Collects the sizes of forcing dimensions from the input YAXArray.

# Arguments:
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
- `in_yax`: The input YAXArray containing forcing data.

# Returns:
- A NamedTuple `f_sizes` where each dimension name is paired with its size.

# Notes:
- The function retrieves the size of the time dimension and spatial dimensions specified in the experiment configuration.
- If the dimension is not directly accessible, it uses `DimensionalData.lookup` to retrieve the size.
"""
function collectForcingSizes(info, in_yax)
    time_dim_name = Symbol(info.experiment.data_settings.forcing.data_dimension.time)
    dnames = Symbol[]
    dsizes = []
    push!(dnames, time_dim_name)
    if time_dim_name in in_yax
        push!(dsizes, length(getproperty(in_yax, time_dim_name)))
    else
        push!(dsizes, length(DimensionalData.lookup(in_yax, time_dim_name)))
    end
    for space ∈ info.experiment.data_settings.forcing.data_dimension.space
        push!(dnames, Symbol(space))
        push!(dsizes, length(getproperty(in_yax, Symbol(space))))
    end
    f_sizes = (; Pair.(dnames, dsizes)...)
    return f_sizes
end

"""
    collectForcingHelpers(info, f_sizes, f_dimensions)

Generates a NamedTuple of helper information for forcing data.

# Arguments:
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
- `f_sizes`: A NamedTuple containing the sizes of forcing dimensions.
- `f_dimensions`: A NamedTuple containing the dimensions of the forcing data.

# Returns:
- A NamedTuple `f_helpers` containing helper information for forcing data.

# Notes:
- Includes dimensions, axes, subset information, and sizes for the forcing data.
"""
function collectForcingHelpers(info, f_sizes, f_dimensions)
    f_helpers = (;)
    f_helpers = setTupleField(f_helpers, (:dimensions, info.experiment.data_settings.forcing.data_dimension))
    f_helpers = setTupleField(f_helpers, (:axes, f_dimensions))
    if hasproperty(info.experiment.data_settings.forcing, :subset)
        f_helpers = setTupleField(f_helpers, (:subset, info.experiment.data_settings.forcing.subset))
    else
        f_helpers = setTupleField(f_helpers, (:subset, nothing))
    end
    f_helpers = setTupleField(f_helpers, (:sizes, f_sizes))
    return f_helpers
end

"""
    createForcingNamedTuple(incubes, f_sizes, f_dimensions, info)

Creates a NamedTuple containing forcing data and metadata.

# Arguments:
- `incubes`: A collection of input cubes (YAXArray) containing forcing data.
- `f_sizes`: A NamedTuple containing the sizes of forcing dimensions.
- `f_dimensions`: A NamedTuple containing the dimensions of the forcing data.
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.

# Returns:
- A NamedTuple `forcing` containing:
  - `data`: The processed input cubes.
  - `dims`: The dimensions of the forcing data.
  - `variables`: The names of the forcing variables.
  - `f_types`: The types of the forcing data (e.g., `ForcingWithTime` or `ForcingWithoutTime`).
  - `helpers`: Helper information for the forcing data.

# Notes:
- Processes the input cubes to determine their types and dimensions.
- Helper information is generated using `collectForcingHelpers`.
"""
function createForcingNamedTuple(incubes, f_sizes, f_dimensions, info)
    showInfo(getForcing, @__FILE__, @__LINE__, "processing forcing helpers...")
    @debug "     ::dimensions::"
    indims = getDataDims.(incubes, Ref(Symbol.(info.experiment.data_settings.forcing.data_dimension.space)))
    @debug "     ::variable names::"
    forcing_vars = keys(info.experiment.data_settings.forcing.variables)
    f_helpers = collectForcingHelpers(info, f_sizes, f_dimensions)
    input_array_type = getfield(SindbadData, toUpperCaseFirst(info.helpers.run.input_array_type, "Input"))()
    typed_cubes = getInputArrayOfType(incubes, input_array_type)
    data_ts_type=[]
    for incube in typed_cubes
        if in(:time, AxisKeys.dimnames(incube))
            push!(data_ts_type, ForcingWithTime())
        else
            push!(data_ts_type, ForcingWithoutTime())
        end 
    end
    data_ts_type = [_dt for _dt in data_ts_type]
    f_types =  Tuple(Tuple.(Pair.(forcing_vars, data_ts_type)))
    @info "\n----------------------------------------------\n"
    forcing = (;
        data=typed_cubes,
        dims=indims,
        variables=forcing_vars,
        f_types = f_types,
        helpers=f_helpers)
    return forcing
end


"""
    getForcing(info::NamedTuple)

Reads forcing data from the `data_path` specified in the experiment configuration and returns a NamedTuple with the forcing data.

# Arguments:
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.

# Returns:
- A NamedTuple `forcing` containing:
  - `data`: The processed input cubes.
  - `dims`: The dimensions of the forcing data.
  - `variables`: The names of the forcing variables.
  - `f_types`: The types of the forcing data (e.g., `ForcingWithTime` or `ForcingWithoutTime`).
  - `helpers`: Helper information for the forcing data.

# Notes:
- Reads forcing data from the specified data path and processes it using the SINDBAD framework.
- Handles spatiotemporal and spatial-only forcing data.
- Applies masks and subsets to the forcing data if specified in the configuration.
"""
function getForcing(info::NamedTuple)
    nc_default = nothing
    forcing_data_settings = info.experiment.data_settings.forcing
    # forcing_data_settings = info.experiment.data_settings.forcing
    data_path = forcing_data_settings.default_forcing.data_path
    if !isnothing(data_path)
        data_path = getAbsDataPath(info, data_path)
        showInfo(getForcing, @__FILE__, @__LINE__, "default_data_path: $(data_path)")
        nc_default = loadDataFile(data_path)
    end
    data_backend = getfield(SindbadData, toUpperCaseFirst(info.helpers.run.input_data_backend, "Backend"))()

    forcing_mask = nothing
    if :sel_mask ∈ keys(forcing_data_settings)
        if !isnothing(forcing_data_settings.forcing_mask.data_path)
            mask_path = getAbsDataPath(info, forcing_data_settings.forcing_mask.data_path)
            _, forcing_mask = getYaxFromSource(nothing, mask_path, nothing, forcing_data_settings.forcing_mask.source_variable, info, data_backend)
            forcing_mask = booleanizeArray(forcing_mask)
        end
    end

    default_info = info.experiment.data_settings.forcing.default_forcing
    forcing_vars = keys(forcing_data_settings.variables)
    tar_dims = getTargetDimensionOrder(info)
    showInfo(getForcing, @__FILE__, @__LINE__, "getting forcing variables...", n_m=1)
    vinfo = nothing
    f_sizes = nothing
    f_dimension = nothing
    num_type = Val{info.helpers.numbers.num_type}()
    incubes = map(forcing_vars) do k
        nc = nc_default
        vinfo = getCombinedNamedTuple(default_info, forcing_data_settings.variables[k])
        data_path_v = getAbsDataPath(info, getfield(vinfo, :data_path))
        nc, yax = getYaxFromSource(nc, data_path, data_path_v, vinfo.source_variable, info, data_backend)
        incube = subsetAndProcessYax(yax, forcing_mask, tar_dims, vinfo, info, num_type)
        showInfo(nothing, @__FILE__, @__LINE__, "$(k): $(vinfo.source_variable)", n_m=4)
        if vinfo.space_time_type == "spatiotemporal" && isnothing(f_sizes)
            f_sizes = collectForcingSizes(info, incube)
            f_dimension = getSindbadDims(incube)
        end
        incube
    end
    return createForcingNamedTuple(incubes, f_sizes, f_dimension, info)
end

