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
    # out = setTupleField(out, (:pools, (; seed=0.1)))
    # out = setTupleField(out, (:states, (; seed=0.1)))
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
            "The output depth_dimensions $(poolName) does not exist in the selected model structure. Either add the pool to modelStructure.json or adjust depth_dimensions or output variables in modelRun.json."
        )
    end
end

function getDepthDimensionSizeName(vname::Symbol, info::NamedTuple, land_init::NamedTuple)
    field_name = first(split(string(vname), '.'))
    vname_s = split(string(vname), '.')[end]
    tmp_vars = info.modelRun.output.variables
    dimName = ""
    dimSize = nothing
    if vname in keys(tmp_vars)
        vdim = tmp_vars[vname]
        dimSize = 1
        dimName = vname_s * "_idx"
        if !isnothing(vdim) && isa(vdim, String)
            dimName = vdim
        end
        if isnothing(vdim)
            dimSize = nothing
        elseif isa(vdim, Int64)
            dimSize = vdim
        elseif isa(vdim, String)
            if Symbol(vdim) in keys(info.modelRun.output.depth_dimensions)
                dimSizeK = getfield(info.modelRun.output.depth_dimensions, Symbol(vdim))
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
        dimName = isnothing(dimSize) ? nothing : dimName

    elseif field_name == "pools"
        dimName = vname_s * "_idx"
        dimSize = length(getfield(land_init.pools, Symbol(vname_s)))
    else
        dimName = ""
        dimSize = nothing
    end
    return dimSize, dimName
end

function getOutDims(info, tem_helpers, vname_full, outpath, outformat, land_init, forcing_sizes)
    vname = Symbol(split(string(vname_full), '.')[end])
    inax = info.modelRun.mapping.runEcosystem

    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
    if isnothing(depth_size)
        OutDims(inax...;
            path=joinpath(outpath, "$(vname)$(outformat)"),
            backend=:zarr,
            overwrite=true)
    else
        OutDims(inax[1],
            RangeAxis(depth_name, 1:depth_size),
            inax[2:end]...;
            path=joinpath(outpath, "$(vname)$(outformat)"),
            backend=:zarr,
            overwrite=true)
        # OutDims(RangeAxis(depth_name, 1:depth_size),inax..., path=joinpath(outpath, "$(vname)$(outformat)"), backend=:zarr, overwrite=true)
    end
end

function getOutDims(info, tem_helpers, vname_full, land_init, forcing_sizes, ::Val{:array})
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
    ar = nothing
    ax_vals = values(forcing_sizes)
    if isnothing(depth_size)
        depth_size = 1
    end
    # ar = Array{Real, length(values(forcing_sizes))+1}(undef, ax_vals[1], depth_size, ax_vals[2:end]...);
    ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.modelRun.rules.forward_diff),
        length(values(forcing_sizes)) + 1}(undef,
        ax_vals[1],
        depth_size,
        ax_vals[2:end]...)
    # ar = Array{tem_helpers.numbers.num_type, length(values(forcing_sizes))+1}(undef, ax_vals[1], depth_size, ax_vals[2:end]...);
    return ar .= info.tem.helpers.numbers.sNT(NaN)
end

function getOutDims(info, tem_helpers, vname_full, land_init, forcing_sizes, ::Val{:sizedarray})
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
    ar = nothing
    ax_vals = values(forcing_sizes)
    if isnothing(depth_size)
        depth_size = 1
    end
    ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.modelRun.rules.forward_diff),
        length(values(forcing_sizes)) + 1}(undef,
        ax_vals[1],
        depth_size,
        ax_vals[2:end]...)
    return mar = SizedArray{Tuple{size(ar)...},eltype(ar)}(undef)
end

function getOutDims(info, tem_helpers, vname_full, land_init, forcing_sizes, ::Val{:marray})
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info, land_init)
    ar = nothing
    ax_vals = values(forcing_sizes)
    if isnothing(depth_size)
        depth_size = 1
    end
    ar = Array{getOutArrayType(tem_helpers.numbers.num_type, info.modelRun.rules.forward_diff),
        length(values(forcing_sizes)) + 1}(undef,
        ax_vals[1],
        depth_size,
        ax_vals[2:end]...)
    return mar = MArray{Tuple{size(ar)...},eltype(ar)}(undef)
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

function setupBaseOutput(info::NamedTuple, tem_helpers::NamedTuple)
    forcing_sizes = info.tem.forcing.sizes
    @info "setupOutput: creating initial out/land..."
    land_init = createLandInit(info.pools, tem_helpers, info.tem.models)
    outformat = info.modelRun.output.format
    @info "setupOutput: getting data variables..."

    datavars = if hasproperty(info, :optim)
        map(info.optim.variables.obs) do vo
            vn = getfield(info.optim.variables.optim, vo)
            Symbol(string(vn[1]) * "." * string(vn[2]))
        end
    else
        map(Iterators.flatten(info.tem.variables)) do vn
            ForwardSindbad.getOrderedOutputList(collect(keys(info.modelRun.output.variables)), vn)
        end
    end

    output_tuple = (;)
    output_tuple = setTupleField(output_tuple, (:land_init, land_init))
    @info "setupOutput: getting output dimension for yaxarray..."
    outdims = map(datavars) do vn
        return getOutDims(info, tem_helpers, vn, info.output.data, outformat, land_init, forcing_sizes)
    end
    output_tuple = setTupleField(output_tuple, (:dims, outdims))
    @info "setupOutput: creating array output"
    outarray = map(datavars) do vn
        getOutDims(info,
            tem_helpers,
            vn,
            land_init,
            forcing_sizes,
            Val(Symbol(info.modelRun.output.output_array_type)))
    end
    output_tuple = setTupleField(output_tuple, (:data, outarray))


    vnames = if hasproperty(info, :optim)
        map(info.optim.variables.obs) do vo
            vn = getfield(info.optim.variables.optim, vo)
            vn[2]
        end
    else
        collect(Iterators.flatten(info.tem.variables))
    end
    output_tuple = setTupleField(output_tuple, (:variables, vnames))

    ovro = getVariableFields(datavars)
    output_tuple = setTupleField(output_tuple, (:ordered_variables, ovro))


    if info.modelRun.flags.runOpti || tem_helpers.run.calcCost
        @info "setupOutput: getting parameter output for optimization..."
        output_tuple = setupOptiOutput(info, output_tuple)
    end
    println("----------------------------------------------")
    return output_tuple
end

function setupOutput(info::NamedTuple)
    return setupBaseOutput(info, info.tem.helpers)
end

function setupOutput(info::NamedTuple, tem_helpers::NamedTuple)
    return setupBaseOutput(info, tem_helpers)
end

function setupOptiOutput(info::NamedTuple, output::NamedTuple)
    params = info.optim.optimized_parameters
    paramaxis = CategoricalAxis("parameter", params)
    od = OutDims(paramaxis;
        path=joinpath(info.output.optim,
            "optimized_parameters$(info.modelRun.output.format)"),
        backend=:zarr,
        overwrite=true)
    # od = OutDims(paramaxis)
    # list of parameter
    output = setTupleField(output, (:paramdims, od))
    return output
end
