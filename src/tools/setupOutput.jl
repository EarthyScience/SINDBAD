export createLandInit, setupOutput, setupOptiOutput

"""
    createLandInit(info)
create the initial out named tuple with subfields for pools, states, and all selected models.
"""
function createLandInit(info::NamedTuple)
    initPools = getInitPools(info)
    initStates = getInitStates(info)
    out = (; fluxes=(;), pools=initPools, states=initStates)
    sortedModels = sort([_sm for _sm in info.tem.models.selected_models.model])
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

function getOutDims(info, vname_full, outpath, outformat)
    vname = Symbol(split(string(vname_full), '.')[end])
    depth_size, depth_name = getDepthDimensionSizeName(vname_full, info)
    if isnothing(depth_size) || depth_size == 1
        OutDims("Time", path=joinpath(outpath, "$(vname)$(outformat)"), overwrite=true)
    else
        OutDims(RangeAxis(depth_name, 1:depth_size),"Time", path=joinpath(outpath, "$(vname)$(outformat)"), overwrite=true)
    end
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
    land_init = createLandInit(info)
    outformat = info.modelRun.output.format
    @info "setupOutput: getting data variables..."
    datavars = map(Iterators.flatten(info.tem.variables)) do vn
        getOrderedOutputList(keys(info.modelRun.output.variables) |> collect, vn)
    end
    @info "setupOutput: getting output dimension..."
    outdims = map(datavars) do vn
        getOutDims(info, vn, info.output.data, outformat)
    end
    vnames = collect(Iterators.flatten(info.tem.variables))
    output_tuple = (; land_init=land_init, dims=outdims, variables = vnames)
    if info.modelRun.flags.runOpti
        @info "setupOutput: getting parameter output for optimization..."
        output_tuple = setupOptiOutput(info, output_tuple);
    end
    println("----------------------------------------------")
    return output_tuple
end

function setupOptiOutput(info::NamedTuple, output::NamedTuple)
    params = info.optim.optimized_parameters
    paramaxis = CategoricalAxis("parameter", params)
    od = OutDims(paramaxis, path=joinpath(info.output.optim, "optimized_parameters$(info.modelRun.output.format)"), overwrite=true)
    # od = OutDims(paramaxis)
     # list of parameter
    output = setTupleField(output, (:paramdims, od))
    return output
end