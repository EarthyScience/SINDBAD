export createLandInit, setupOutput, setupOptiOutput

"""
    createLandInit(info)
create the initial out named tuple with subfields for pools, states, and all selected models.
"""
function createLandInit(info_tem::NamedTuple)
    initPools = getInitPools(info_tem)
    initStates = getInitStates(info_tem)
    out = (; fluxes=(;), pools=initPools, states=initStates)
    sortedModels = sort([_sm for _sm in info_tem.models.selected_models.model])
    for model in sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end

function getPoolSize(info::NamedTuple, poolName::Symbol)
    poolsize = nothing
    for elem in keys(info.tem.pools)
        zixelem = getfield(info.tem.pools, elem)[:zix]
        if poolName in keys(zixelem)
            return length(getfield(zixelem, poolName))
        end
    end
    if isnothing(poolsize)
        error("The output depth_dimensions $(poolName) does not exist in the selected model structure. Either add the pool to modelStructure.json or adjust depth_dimensions or output variables in modelRun.json.")
    end
end

function getDepthDimensionSizeName(vname::Symbol, info::NamedTuple)
    vname_s = split(string(vname), '.')[end]
    tmp_vars = info.modelRun.output.variables
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
                dimSize = getPoolSize(info, Symbol(dimSizeK))
            end
        else
            error("The output depth dimension for $(vname) is specified as $(vdim) but this key does not exist in depth_dimensions. Either add it to depth_dimensions or add a numeric value.")
        end
    else
        error("The depth dimension for $(vname) is specified as $(typeof(vdim)). Only null, integers, or string keys to depth_dimensions are accepted.")
    end
    dimName = isnothing(dimSize) ? nothing : dimName
        
    return dimSize, dimName      
end

function getOutDimsOri(info, vname_full, outpath, outformat)
    vname = Symbol(split(string(vname_full), '.')[end])
    inax =  info.modelRun.mapping.runEcosystem
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info)
    if isnothing(depth_size) || depth_size == 1
        OutDims(inax..., path=joinpath(outpath, "$(vname)$(outformat)"), backend = :zarr, overwrite=true)
    else
        OutDims(RangeAxis(depth_name, 1:depth_size),inax..., path=joinpath(outpath, "$(vname)$(outformat)"), backend=:zarr, overwrite=true)
    end
end

function getOutDimsOri(info, vname_full, ::Val{:array})
    # vname = Symbol(split(string(vname_full), '.')[end])
    # inax =  info.modelRun.mapping.runEcosystem
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info)
    if isnothing(depth_size) || depth_size == 1
        Array{info.tem.helpers.numbers.numType, length(values(info.tem.helpers.run.loop))}(undef, values(info.tem.helpers.run.loop)...);
    else
        Array{info.tem.helpers.numbers.numType, length(values(info.tem.helpers.run.loop))+1}(undef, depth_size, values(info.tem.helpers.run.loop)...);
    end
end

function getOutDims(info, vname_full, outpath, outformat)
    vname = Symbol(split(string(vname_full), '.')[end])
    inax =  info.modelRun.mapping.runEcosystem
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info)
    if isnothing(depth_size)
        OutDims(inax..., path=joinpath(outpath, "$(vname)$(outformat)"), backend = :zarr, overwrite=true)
    else
        OutDims(inax[1], RangeAxis(depth_name, 1:depth_size),inax[2:end]..., path=joinpath(outpath, "$(vname)$(outformat)"), backend=:zarr, overwrite=true)
        # OutDims(RangeAxis(depth_name, 1:depth_size),inax..., path=joinpath(outpath, "$(vname)$(outformat)"), backend=:zarr, overwrite=true)
    end
end

function getOutDims(info, vname_full, ::Val{:array})
    # vname = Symbol(split(string(vname_full), '.')[end])
    # inax =  info.modelRun.mapping.runEcosystem
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info)
    ar = nothing
    if isnothing(depth_size)
        ar = Array{info.tem.helpers.numbers.numType, length(values(info.tem.helpers.run.loop))}(undef, values(info.tem.helpers.run.loop)...);
    else
        ax_vals = values(info.tem.helpers.run.loop)
        ar = Array{info.tem.helpers.numbers.numType, length(values(info.tem.helpers.run.loop))+1}(undef, ax_vals[1], depth_size, ax_vals[2:end]...);
        # Array{info.tem.helpers.numbers.numType, length(values(info.tem.helpers.run.loop))+1}(undef, depth_size, values(info.tem.helpers.run.loop)...);
    end
    ar .= info.tem.helpers.numbers.sNT(NaN)
end

function getOrderedOutputList(varlist::AbstractArray, var_o::Symbol)
    for var in varlist
        vname = Symbol(split(string(var), '.')[end])
        if vname === var_o
            return var
        end
    end
end

function setupOutput(info::NamedTuple)
    @info "setupOutput: creating initial out/land..."
    land_init = createLandInit(info.tem)
    outformat = info.modelRun.output.format
    @info "setupOutput: getting data variables..."
    datavars = map(Iterators.flatten(info.tem.variables)) do vn
        getOrderedOutputList(keys(info.modelRun.output.variables) |> collect, vn)
    end
    @info "setupOutput: getting output dimension..."
    output_tuple = (;)
    output_tuple = setTupleField(output_tuple, (:land_init, land_init))
    outdims = map(datavars) do vn
        getOutDims(info, vn, info.output.data, outformat)
    end
    output_tuple = setTupleField(output_tuple, (:dims, outdims))
    if info.tem.helpers.run.runOpti || info.tem.helpers.run.calcCost
        outarray = map(datavars) do vn
            getOutDims(info, vn, Val(:array))
        end
        output_tuple = setTupleField(output_tuple, (:data, outarray))
    end
    vnames = collect(Iterators.flatten(info.tem.variables))
    output_tuple = setTupleField(output_tuple, (:variables, vnames))
    # output_tuple = (; land_init=land_init, dims=outdims, variables = vnames)
    if info.modelRun.flags.runOpti || info.tem.helpers.run.calcCost
        @info "setupOutput: getting parameter output for optimization..."
        output_tuple = setupOptiOutput(info, output_tuple);
    end
    println("----------------------------------------------")
    return output_tuple
end

function setupOptiOutput(info::NamedTuple, output::NamedTuple)
    params = info.optim.optimized_parameters
    paramaxis = CategoricalAxis("parameter", params)
    od = OutDims(paramaxis, path=joinpath(info.output.optim, "optimized_parameters$(info.modelRun.output.format)"), backend=:zarr, overwrite=true)
    # od = OutDims(paramaxis)
     # list of parameter
    output = setTupleField(output, (:paramdims, od))
    return output
end