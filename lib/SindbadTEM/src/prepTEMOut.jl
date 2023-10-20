export getOutDims
export getOutDimsArrays
export prepTEMOut
export setupOptiOutput


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
function getNumericArrays(info, land, forcing_sizes)
    tem_output = info.output
    tem_helpers = info.helpers
    v_ind = 1

    outarray = map(tem_output.variables) do vname_full
        depth_size = 1
        if isnothing(land)
            depth_info = tem_output.depth_info[v_ind]
            depth_size = first(depth_info)
        else
            depth_size, _ = getDepthDimensionSizeName(vname_full, info, land)
        end
        @show vname_full, depth_size
        ar = nothing
        ax_vals = values(forcing_sizes)
        ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.helpers.run.use_forward_diff),
            length(values(forcing_sizes)) + 1}(undef,
            ax_vals[1],
            depth_size,
            ax_vals[2:end]...)
        v_ind += 1
        ar .= info.helpers.numbers.num_type(NaN)
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
function getOutDims(info, forcing_helpers)
    outdims = getOutDims(info, forcing_helpers, info.helpers.run.output_array_type)
    return outdims
end



"""
    getOutDims(output_vars, info, land, forcing_helpers, ::OutputArray)

get the dimensions for SINDBAD output using base Array as array backend

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::Union{OutputArray, OutputMArray, OutputSizedArray`: a type dispatch for using base Array, MArray or SizedArray as output data
"""
function getOutDims(info, forcing_helpers, ::Union{OutputArray, OutputMArray, OutputSizedArray})
    outdims_pairs = getOutDimsPairs(info.output, forcing_helpers)
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
function getOutDims(info, forcing_helpers, ::OutputYAXArray)
    outdims_pairs = getOutDimsPairs(info.output, forcing_helpers);
    info.settings.forcing.data_dimension.time
    space_dims = Symbol.(info.settings.forcing.data_dimension.space)
    var_dims = map(outdims_pairs) do dim_pairs
        od = []
        for _dim in dim_pairs
            if first(_dim) ∉ space_dims
                push!(od, Dim{first(_dim)}(last(_dim)))
            end
        end
        Tuple(od)
    end
    v_index = 1
    outdims = map(info.output.variables) do vname_full
        vname = string(last(vname_full))
        vdims = var_dims[v_index]
        outformat = info.settings.experiment.model_output.format
        backend = outformat == "nc" ? :netcdf : :zarr
        out_dim = OutDims(vdims...;
        path=joinpath(info.output.file_info.file_prefix, "$(vname).$(outformat)"),
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
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
"""
function getOutDimsArrays(info, land, forcing_helpers)
    outdims, outarray = getOutDimsArrays(info, land, forcing_helpers, info.helpers.run.output_array_type)
    return outdims, outarray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputArray)

get the dimensions and corresponding data for SINDBAD output using base Array as array backend

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputArray`: a type dispatch for using base Array as output data
"""
function getOutDimsArrays(info, land, forcing_helpers, oarr::OutputArray)
    outdims = getOutDims(info, forcing_helpers, oarr)
    outarray = getNumericArrays(info, land, forcing_helpers.sizes)
    return outdims, outarray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputMArray)

get the dimensions and corresponding data for SINDBAD output using MArray as array backend

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputMArray`: a type dispatch for using MArray as output data
"""
function getOutDimsArrays(info, land, forcing_helpers, omarr::OutputMArray)
    outdims = getOutDims(info, forcing_helpers, omarr)
    outarray = getNumericArrays(info, land, forcing_helpers.sizes)
    marray = MArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, marray
end


"""
    getOutDimsArrays(output_vars, info, tem_helpers, land, forcing_helpers, ::OutputSizedArray)

get the dimensions and corresponding data for SINDBAD output using SizedArray as array backend

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputSizedArray`: a type dispatch for using SizedArray as output data
"""
function getOutDimsArrays(info, land, forcing_helpers, osarr::OutputSizedArray)
    outdims = getOutDims(info, forcing_helpers, osarr)
    outarray = getNumericArrays(info, land, forcing_helpers.sizes)
    sized_array = SizedArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, sized_array
end


"""
    getOutDimsArrays(output_vars, info, _, land, _, ::OutputYaxArray)

get the dimensions and corresponding data for SINDBAD output using YAXArray as array backend

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `land`: SINDBAD land with all fields and subfields
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `::OutputYAXArray`: a type dispatch for using YAXArray as output data
"""
function getOutDimsArrays(info, land, forcing_helpers, oayax::OutputYAXArray)
    outdims = getOutDims(info, forcing_helpers, oayax)
    outarray = nothing
    return outdims, outarray
end


"""
    getOutDimsPairs(tem_output, forcing_helpers; dthres = 1)

creates a pair for each dimension of output variables from the information of forcing dimensions

# Arguments:
- `tem_output`: helper NT with necessary information of output variables and z dimension of output arrays
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `dthres`: threshold for number of depth layers to define depth as a new dimension
"""
function getOutDimsPairs(tem_output, forcing_helpers; dthres=1)
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
    opInd = 1
    outdims_pairs = map(tem_output.variables) do vname_full
        depth_info = tem_output.depth_info[opInd]
        depth_size = first(depth_info)
        depth_name = last(depth_info)
        # depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land)
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
        opInd += 1
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
    setupBaseOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)

base function to prepare the output NT for the forward run

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing_helpers`: a NT with information on forcing sizes and dimensions
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function setupBaseOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)
    @info "  prepTEMOut: preparing output and helpers..."
    land = info.land_init
    output_tuple = (;)
    output_tuple = setTupleField(output_tuple, (:land_init, land))
    @debug "     prepTEMOut: getting out variables, dimension and arrays..."
    outdims, outarray = getOutDimsArrays(info, land, forcing_helpers, info.helpers.run.output_array_type)
    output_tuple = setTupleField(output_tuple, (:dims, outdims))
    output_tuple = setTupleField(output_tuple, (:data, outarray))
    output_tuple = setTupleField(output_tuple, (:variables, info.output.variables))

    output_tuple = setupOptiOutput(info, output_tuple, info.helpers.run.run_optimization)
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
    return setupBaseOutput(info, forcing_helpers, info.helpers)
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
function setupOptiOutput(info::NamedTuple, output::NamedTuple, ::DoRunOptimization)
    @debug "     prepTEMOut: getting parameter output for optimization..."
    params = info.optimization.model_parameters_to_optimize
    paramaxis = Dim{:parameter}(params)
    outformat = info.output.format
    backend = outformat == "nc" ? :netcdf : :zarr
    od = OutDims(paramaxis;
        path=joinpath(info.output.dirs.optimization,
            "optimized_parameters.$(outformat)"),
        backend=backend,
        overwrite=true)
    # list of parameter
    output = setTupleField(output, (:parameter_dim, od))
    return output
end


"""
    setupOptiOutput(info::NamedTuple, output::NamedTuple)

create the output fields needed for the optimization experiment

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `output`: a base output NT
"""
function setupOptiOutput(info::NamedTuple, output::NamedTuple, ::DoNotRunOptimization)
    return output
end