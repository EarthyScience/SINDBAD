export createLandInit, setupOutput, setupOptiOutput

"""
createLandInit(info_pools::NamedTuple, info_tem::NamedTuple)

create the initial out named tuple with subfields for pools, states, and all selected models.
"""
function createLandInit(info_pools::NamedTuple, tem_helpers::NamedTuple, tem_models::NamedTuple)
    initPools = getInitPools(info_pools, tem_helpers)
    initStates = getInitStates(info_pools, tem_helpers)
    out = (; fluxes=(;), pools=initPools, states=initStates)::NamedTuple
    sortedModels = sort([_sm for _sm ∈ tem_models.selected_models.model])
    for model ∈ sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end

function getPoolSize(info_pools::NamedTuple, poolName::Symbol)
    poolsize = nothing
    for elem ∈ keys(info_pools)
        zixelem = getfield(info_pools, elem)[:zix]
        if poolName in keys(zixelem)
            return length(getfield(zixelem, poolName))
        end
    end
    if isnothing(poolsize)
        error(
            "The output depth_dimensions $(poolName) does not exist in the selected model structure. Either add the pool to model_structure.json or adjust depth_dimensions or output variables in model_run.json."
        )
    end
end

function getDepthDimensionSizeName(vname::Symbol, info::NamedTuple, land_init::NamedTuple)
    field_name = first(split(string(vname), '.'))
    vname_s = split(string(vname), '.')[end]
    tmp_vars = info.model_run.output.variables
    dimSize = 1
    dimName = vname_s * "_idx"
    if vname in keys(tmp_vars)
        vdim = tmp_vars[vname]
        dimSize = 1
        dimName = vname_s * "_idx"
        if !isnothing(vdim) && isa(vdim, String)
            dimName = vdim
        end
        if isnothing(vdim)
            dimSize = dimSize
        elseif isa(vdim, Int64)
            dimSize = vdim
        elseif isa(vdim, String)
            if Symbol(vdim) in keys(info.model_run.output.depth_dimensions)
                dimSizeK = getfield(info.model_run.output.depth_dimensions, Symbol(vdim))
                if isa(dimSizeK, Int64)
                    dimSize = dimSizeK
                elseif isa(dimSizeK, String)
                    dimSize = getPoolSize(info.pools, Symbol(dimSizeK))
                end
            else
                error(
                    "The output depth dimension for $(vname) is specified as $(vdim) but this key does not exist in depth_dimensions. Either add it to depth_dimensions or add a numeric value."
                )
            end
        else
            error(
                "The depth dimension for $(vname) is specified as $(typeof(vdim)). Only null, integers, or string keys to depth_dimensions are accepted."
            )
        end

    elseif field_name == "pools"
        dimName = vname_s * "_idx"
        dimSize = length(getfield(land_init.pools, Symbol(vname_s)))
    end
    return dimSize, dimName
end

function getOutDimsArrays(datavars, info, _, land_init, _, _, ::Val{:yaxarray})
    outdims = map(datavars) do vname_full
        vname = Symbol(split(string(vname_full), '.')[end])
        inax = info.model_run.mapping.run_ecosystem
        path_output = info.output.data
        outformat = info.model_run.output.format
        depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
        OutDims(inax[1],
            Dim{Symbol(depth_name)}(1:depth_size),
            inax[2:end]...;
            path=joinpath(path_output, "$(vname).$(outformat)"),
            backend=:zarr,
            overwrite=true)
    end
    outarray = nothing
    return outdims, outarray
end

function getNumericArrays(datavars, info, tem_helpers, land_init, forcing_sizes)
    outarray = map(datavars) do vname_full
        depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
        ar = nothing
        ax_vals = values(forcing_sizes)
        ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.model_run.rules.forward_diff),
            length(values(forcing_sizes)) + 1}(undef,
            ax_vals[1],
            depth_size,
            ax_vals[2:end]...)
        ar .= info.tem.helpers.numbers.sNT(NaN)
    end
    return outarray
end

function getOutDimsPairs(datavars, info, tem_helpers, land_init, forcing_helpers; dthres=1)
    forcing_sizes = forcing_helpers.sizes
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
    outdims_pairs = map(datavars) do vname_full
        depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
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

function getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, ::Val{:array})
    forcing_sizes = forcing_helpers.sizes
    outarray = getNumericArrays(datavars, info, tem_helpers, land_init, forcing_sizes)
    outdims_pairs = getOutDimsPairs(datavars, info, tem_helpers, land_init, forcing_helpers)
    outdims = map(outdims_pairs) do dim_pairs
        od = []
        for _dim in dim_pairs
            push!(od, Dim{first(_dim)}(last(_dim)))
        end
        Tuple(od)
    end
    return outdims, outarray

end

function getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, ::Val{:sizedarray})
    outdims, outarray = getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, Val(:array))
    sized_array = SizedArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, sized_array
end

function getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, ::Val{:marray})
    outdims, outarray = getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, Val(:array))
    marray = MArray{Tuple{size(outarray)...},eltype(outarray)}(undef)
    return outdims, marray
end


function getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, ::Val{:keyedarray})
    forcing_sizes = forcing_helpers.sizes
    outarray = getNumericArrays(datavars, info, tem_helpers, land_init, forcing_sizes)
    outdims_pairs = getOutDimsPairs(datavars, info, tem_helpers, land_init, forcing_helpers; dthres=0)

    keyedarray = []
    # keyedarray = outarray
    outdims = []
    for (_di, _dim) in enumerate(outdims_pairs)
        @show _di, length(_dim)
        d_to_push = _dim
        push!(keyedarray, KeyedArray(outarray[_di]; _dim...))
        if length(_dim) > 2
            if length(last(_dim[2])) == 1
                d_to_push = []
                push!(d_to_push, _dim[1])
                foreach(_dim[3:end]) do f_d
                    push!(d_to_push, f_d)
                end
            end
        end
        push!(outdims, Tuple(d_to_push))
    end
    return outdims, keyedarray
end

function getOutArrayType(num_type, forwardDiff)
    return num_type
end

function getOrderedOutputList(varlist::AbstractArray, var_o::Symbol)
    for var ∈ varlist
        vname = Symbol(split(string(var), '.')[end])
        if vname === var_o
            return var
        end
    end
end

"""
function getVariableFields(datavars)
get a namedTuple with field and subfields vectors for extracting data from land
"""
function getVariableFields(datavars)
    vf = Symbol[]
    vsf = Symbol[]
    for _vf ∈ datavars
        push!(vf, Symbol(split(string(_vf), '.')[1]))
        push!(vsf, Symbol(split(string(_vf), '.')[2]))
    end
    ovro = Tuple(Tuple.(Pair.(vf, vsf)))
    return ovro
end

function setupBaseOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)
    @info "     setupOutput: creating initial out/land..."
    land_init = createLandInit(info.pools, tem_helpers, info.tem.models)
    outformat = info.model_run.output.format
    @info "     setupOutput: getting data variables..."

    datavars = if hasproperty(info, :optim)
        map(info.optim.variables.obs) do vo
            vn = getfield(info.optim.variables.optim, vo)
            Symbol(string(vn[1]) * "." * string(vn[2]))
        end
    else
        map(Iterators.flatten(info.tem.variables)) do vn
            ForwardSindbad.getOrderedOutputList(collect(keys(info.model_run.output.variables)), vn)
        end
    end

    output_tuple = (;)
    output_tuple = setTupleField(output_tuple, (:land_init, land_init))
    @info "     setupOutput: getting output dimension and arrays..."
    outdims, outarray = getOutDimsArrays(datavars, info, tem_helpers, land_init, forcing_helpers, Val(Symbol(info.model_run.output.output_array_type)))
    output_tuple = setTupleField(output_tuple, (:dims, outdims))
    output_tuple = setTupleField(output_tuple, (:data, outarray))

    vnames = if hasproperty(info, :optim)
        map(info.optim.variables.obs) do vo
            vn = getfield(info.optim.variables.optim, vo)
            vn[2]
        end
    else
        collect(Iterators.flatten(info.tem.variables))
    end
    # output_tuple = setTupleField(output_tuple, (:variables, vnames))

    ovro = getVariableFields(datavars)
    output_tuple = setTupleField(output_tuple, (:variables, ovro))


    if getBool(info.model_run.flags.run_optimization) || getBool(tem_helpers.run.run_forward_and_cost)
        @info "     setupOutput: getting parameter output for optimization..."
        output_tuple = setupOptiOutput(info, output_tuple)
    end
    println("----------------------------------------------")
    return output_tuple
end

function setupOutput(info::NamedTuple, forcing_helpers::NamedTuple)
    return setupBaseOutput(info, forcing_helpers, info.tem.helpers)
end

function setupOutput(info::NamedTuple, forcing_helpers::NamedTuple, tem_helpers::NamedTuple)
    return setupBaseOutput(info, forcing_helpers, tem_helpers)
end

function setupOptiOutput(info::NamedTuple, output::NamedTuple)
    params = info.optim.optimized_parameters
    paramaxis = Dim{:parameter}(params)
    od = OutDims(paramaxis;
        path=joinpath(info.output.optim,
            "optimized_parameters$(info.model_run.output.format)"),
        backend=:zarr,
        overwrite=true)
    # od = OutDims(paramaxis)
    # list of parameter
    output = setTupleField(output, (:paramdims, od))
    return output
end
