export createLandInit
export getOutDims
export getOutDimsArrays
export prepTEMOut
export setupOptiOutput

"""
    createLandInit(info_pools::NamedTuple, tem_helpers::NamedTuple, tem_models::NamedTuple)

create the initial out named tuple with subfields for pools, states, and all selected models.

# Arguments:
- `info_pools`: information of SINDBAD pools in the model structure
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
"""
function createLandInit(info_pools::NamedTuple, tem_helpers::NamedTuple, tem_models::NamedTuple)
    init_pools = getInitPools(info_pools, tem_helpers)
    initial_states = getInitStates(info_pools, tem_helpers)
    out = (; fluxes=(;), pools=init_pools, states=initial_states)::NamedTuple
    sortedModels = sort([_sm for _sm ∈ tem_models.selected_models.model])
    for model ∈ sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end

"""
    getPoolSize(info_pools::NamedTuple, pool_name::Symbol)

get the size of a pool variable from the information in model structure settings 

# Arguments:
- `info_pools`: part of info with information of the pool in the selected model structure
- `pool_name`: the name of the pool
"""
function getPoolSize(info_pools::NamedTuple, pool_name::Symbol)
    poolsize = nothing
    for elem ∈ keys(info_pools)
        zixelem = getfield(info_pools, elem)[:zix]
        if pool_name in keys(zixelem)
            return length(getfield(zixelem, pool_name))
        end
    end
    if isnothing(poolsize)
        error(
            "The output depth_dimensions $(pool_name) does not exist in the selected model structure. Either add the pool to model_structure.json or adjust depth_dimensions or output variables in model_run.json."
        )
    end
end

"""
    getDepthDimensionSizeName(vname::Symbol, info::NamedTuple, land::NamedTuple)

a helper function to get the name and size of the depth dimension for a given variable

# Arguments:
- `vname`: variable name
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
"""
function getDepthDimensionSizeName(v_full_pair, info::NamedTuple, land::NamedTuple)
    v_full_str = getVariableString(v_full_pair)
    v_full_sym = Symbol(v_full_str)
    field_name = first(split(v_full_str, '.'))
    v_name = split(v_full_str, '.')[end]
    tmp_vars = info.experiment.model_output.variables
    dim_size = 1
    dim_name = v_name * "_idx"
    field_name_sym = Symbol(field_name)
    v_name_sym = Symbol(v_name)
    if v_full_sym in keys(tmp_vars)
        v_dim = tmp_vars[v_full_sym]
        dim_size = 1
        dim_name = v_name * "_idx"
        if !isnothing(v_dim) && isa(v_dim, String)
            dim_name = v_dim
        end
        if isnothing(v_dim)
            dim_size = dim_size
        elseif isa(v_dim, Int64)
            dim_size = v_dim
        elseif isa(v_dim, String)
            if Symbol(v_dim) in keys(info.experiment.model_output.depth_dimensions)
                dim_size_K = getfield(info.experiment.model_output.depth_dimensions, Symbol(v_dim))
                if isa(dim_size_K, Int64)
                    dim_size = dim_size_K
                elseif isa(dim_size_K, String)
                    dim_size = getPoolSize(info.pools, Symbol(dim_size_K))
                end
            else
                error(
                    "The output depth dimension for $(v_name) is specified as $(v_dim) but this key does not exist in depth_dimensions. Either add it to depth_dimensions or add a numeric value."
                )
            end
        else
            error(
                "The depth dimension for $(v_name) is specified as $(typeof(v_dim)). Only null, integers, or string keys to depth_dimensions are accepted."
            )
        end

    elseif hasproperty(land, field_name_sym)
        land_field = getproperty(land, field_name_sym)
        if hasproperty(land_field, v_name_sym)
            land_subfield = getproperty(land_field, v_name_sym)
            if isa(land_subfield, AbstractArray)
                dim_size = length(land_subfield)
            elseif isa(land_subfield, Number)
                dim_size = 1
            else
                dim_size = 0
            end
        end
    end
    return dim_size, dim_name
end


"""
    getNumericArrays(output_vars, info, tem_helpers, land, forcing_sizes)

a helper function to define/instantiate arrays for output

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `land`: SINDBAD land with all fields and subfields
- `forcing_sizes`: a NT with forcing dimensions and their sizes
"""
function getNumericArrays(output_vars, info, tem_helpers, land, forcing_sizes)
    outarray = map(output_vars) do vname_full
        depth_size, _ = getDepthDimensionSizeName(vname_full, info, land)
        ar = nothing
        ax_vals = values(forcing_sizes)
        ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.tem.helpers.run.use_forward_diff),
            length(values(forcing_sizes)) + 1}(undef,
            ax_vals[1],
            depth_size,
            ax_vals[2:end]...)
        ar .= info.tem.helpers.numbers.sNT(NaN)
    end
    outarray = [outarray...]
    return outarray
end


"""
    getOutDims(output_vars, info, forcing_helpers)

intermediary helper function to only get the the dimensions for SINDBAD output

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
"""
function getOutDims(output_vars, info, forcing_helpers)
    land = createLandInit(info.pools, info.tem.helpers, info.tem.models)
    outdims = getOutDims(output_vars, info, land, forcing_helpers, info.tem.helpers.run.output_array_type)
    return outdims
end



"""
    getOutDims(output_vars, info, land, forcing_helpers, ::OutputArray)

get the dimensions for SINDBAD output using base Array as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::Union{OutputArray, OutputMArray, OutputSizedArray`: a type dispatch for using base Array, MArray or SizedArray as output data
"""
function getOutDims(output_vars, info, land, forcing_helpers, ::Union{OutputArray, OutputMArray, OutputSizedArray})
    outdims_pairs = getOutDimsPairs(output_vars, info, land, forcing_helpers)
    outdims = map(outdims_pairs) do dim_pairs
        od = []
        for _dim in dim_pairs
            push!(od, Dim{first(_dim)}(last(_dim)))
        end
        Tuple(od)
    end
    return outdims
end

"""
    getOutDims(output_vars, info, land, forcing_helpers, ::OutputYaxArray)

get the dimensions for SINDBAD output using YAXArray as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputYAXArray`: a type dispatch for using YAXArray as output data
"""
function getOutDims(output_vars, info, land, forcing_helpers, ::OutputYAXArray)
    outdims_pairs = getOutDimsPairs(output_vars, info, land, forcing_helpers);
    info.forcing.data_dimension.time
    space_dims = Symbol.(info.forcing.data_dimension.space)
    var_dims = map(outdims_pairs) do dim_pairs
        od = []
        for _dim in dim_pairs
            if first(_dim) ∉ space_dims
                push!(od, Dim{first(_dim)}(last(_dim)))
            end
        end
        Tuple(od)
    end
    out_file_info = getOutputFileInfo(info);
    v_index = 1
    outdims = map(output_vars) do vname_full
        vname = string(last(vname_full))
        vdims = var_dims[v_index]
        outformat = info.experiment.model_output.format
        backend = outformat == "nc" ? :netcdf : :zarr
        # depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land)
        out_dim = OutDims(vdims...;
        path=joinpath(out_file_info.file_prefix, "$(vname).$(outformat)"),
        backend=backend,
        overwrite=true)
        v_index += 1
        out_dim
    end
    return outdims
end


"""
    getOutDimsArrays(output_vars, info, land, forcing_helpers)

intermediary function to get the dimensions and corresponding data for SINDBAD output

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
"""
function getOutDimsArrays(output_vars, info, land, forcing_helpers)
    outdims, outarray = getOutDimsArrays(output_vars, info, info.tem.helpers, land, forcing_helpers, info.tem.helpers.run.output_array_type)
    return outdims, outarray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputArray)

get the dimensions and corresponding data for SINDBAD output using base Array as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputArray`: a type dispatch for using base Array as output data
"""
function getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, oarr::OutputArray)
    outdims = getOutDims(output_vars, info, land, forcing_helpers, oarr)
    outarray = getNumericArrays(output_vars, info, tem_helpers, land, forcing_helpers.sizes)
    return outdims, outarray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputMArray)

get the dimensions and corresponding data for SINDBAD output using MArray as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputMArray`: a type dispatch for using MArray as output data
"""
function getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, omarr::OutputMArray)
    outdims = getOutDims(output_vars, info, land, forcing_helpers, omarr)
    outarray = getNumericArrays(output_vars, info, tem_helpers, land, forcing_helpers.sizes)
    marray = MArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, marray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputSizedArray)

get the dimensions and corresponding data for SINDBAD output using SizedArray as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputSizedArray`: a type dispatch for using SizedArray as output data
"""
function getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, osarr::OutputSizedArray)
    outdims = getOutDims(output_vars, info, land, forcing_helpers, osarr)
    outarray = getNumericArrays(output_vars, info, tem_helpers, land, forcing_helpers.sizes)
    sized_array = SizedArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, sized_array
end


"""
    getOutDimsArrays(output_vars, info, _, land, _, ::OutputYaxArray)

get the dimensions and corresponding data for SINDBAD output using YAXArray as array backend

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `_`: unused argument
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputYAXArray`: a type dispatch for using YAXArray as output data
"""
function getOutDimsArrays(output_vars, info, _, land, forcing_helpers, oayax::OutputYAXArray)
    outdims = getOutDims(output_vars, info, land, forcing_helpers, oayax)
    outarray = nothing
    return outdims, outarray
end


"""
    getOutDimsPairs(output_vars, info, land, forcing_helpers; dthres = 1)

creates a pair for each dimension of output variables from the information of forcing dimensions

# Arguments:
- `output_vars`: a vector of pairs for each output variable with land field as the key and land subfield as the value
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `dthres`: threshold for number of depth layers to define depth as a new dimension
"""
function getOutDimsPairs(output_vars, info, land, forcing_helpers; dthres=1)
    forcing_axes = forcing_helpers.axes
    dim_loops = first.(forcing_axes)
    axes_dims_pairs = []
    if !isnothing(forcing_helpers.dimensions.permute)
        dim_perms = Symbol.(forcing_helpers.dimensions.permute)
        if dim_loops !== dim_perms
            for ix in eachindex(dim_perms)
                dp_i = dim_perms[ix]
                dl_ind = findall(x -> x == dp_i, dim_loops)[1]
                f_a = forcing_axes[dl_ind]
                ax_dim = Pair(first(f_a), last(f_a))
                push!(axes_dims_pairs, ax_dim)
            end
        end
    else
        axes_dims_pairs = map(x -> Pair(first(x), last(x)), forcing_axes)
    end
    outdims_pairs = map(output_vars) do vname_full
        depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land)
        od = []
        push!(od, axes_dims_pairs[1])
        if depth_size > dthres
            if depth_size == 1
                depth_name = "idx"
            end
            push!(od, Pair(Symbol(depth_name), (1:depth_size)))
        end
        foreach(axes_dims_pairs[2:end]) do f_d
            push!(od, f_d)
        end
        Tuple(od)
    end
    return outdims_pairs
end

"""
    getOutArrayType(num_type, ::DoUseForwardDiff)

return the type of elements to be used in the output array

# Arguments:
- `num_type`: the given type from the given model settings
- `::DoUseForwardDiff`: a type dispatch to use a special type for forwarddiff cases
"""
function getOutArrayType(_, ::DoUseForwardDiff)
    return Real
end


"""
    getOutArrayType(num_type, ::DoNotUseForwardDiff)

return the type of elements to be used in the output array

# Arguments:
- `num_type`: the given type from the given model settings
- `::DoNotUseForwardDiff`: a type dispatch to not use a special type for forwarddiff cases
"""
function getOutArrayType(num_type, ::DoNotUseForwardDiff)
    return num_type
end


"""
    getVariableString(var_pair)

return a vector of pairs with field and subfield of land from the list of variables (output_vars) in field.subfield convention
"""
function getVariableString(var_pair::Tuple, sep=".")
    return string(first(var_pair)) * sep * string(last(var_pair))
end


"""
    setupBaseOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)

base function to prepare the output NT for the forward run

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function setupBaseOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)
    @info "  prepTEMOut: preparing output variables and helpers..."
    @debug "     prepTEMOut: creating initial out/land..."
    land = createLandInit(info.pools, tem_helpers, info.tem.models)
    output_tuple = (;)
    output_tuple = setTupleField(output_tuple, (:land_init, land))
    @debug "     prepTEMOut: getting out variables, dimension and arrays..."
    outdims, outarray = getOutDimsArrays(info.tem.variables, info, tem_helpers, land, forcing_helpers, info.tem.helpers.run.output_array_type)
    output_tuple = setTupleField(output_tuple, (:dims, outdims))
    output_tuple = setTupleField(output_tuple, (:data, outarray))
    output_tuple = setTupleField(output_tuple, (:variables, info.tem.variables))

    if info.experiment.flags.run_optimization || info.experiment.flags.calc_cost
        @debug "     prepTEMOut: getting parameter output for optimization..."
        output_tuple = setupOptiOutput(info, output_tuple)
    end
    @debug "\n----------------------------------------------\n"
    return output_tuple
end

"""
    prepTEMOut(info::NamedTuple, forcing_helpers::NamedTuple)

prepare the output NT needed to run TEM using the base helpers

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
"""
function prepTEMOut(info::NamedTuple, forcing_helpers::NamedTuple)
    return setupBaseOutput(info, forcing_helpers, info.tem.helpers)
end

"""
    prepTEMOut(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)

prepare the output NT needed to run TEM using the modified helpers

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function prepTEMOut(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)
    return setupBaseOutput(info, forcing_helpers, tem_helpers)
end

"""
    setupOptiOutput(info::NamedTuple, output::NamedTuple)

create the output fields needed for the optimization experiment

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `output`: a base output NT
"""
function setupOptiOutput(info::NamedTuple, output::NamedTuple)
    params = info.optim.model_parameters_to_optimize
    paramaxis = Dim{:parameter}(params)
    outformat = info.experiment.model_output.format
    backend = outformat == "nc" ? :netcdf : :zarr
    od = OutDims(paramaxis;
        path=joinpath(info.output.optim,
            "optimized_parameters.$(outformat)"),
        backend=backend,
        overwrite=true)
    # list of parameter
    output = setTupleField(output, (:paramdims, od))
    return output
end
