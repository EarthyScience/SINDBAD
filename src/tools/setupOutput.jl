export createInitOut, setupOutput

"""
    createInitOut(info)
create the initial out named tuple with subfields for pools, states, and all selected models.
"""
function createInitOut(info)
    initPools = getInitPools(info)
    initStates = getInitStates(info)
    out = (; fluxes=(;), pools=initPools, states=initStates)
    sortedModels = sort([_sm for _sm in info.tem.models.selected_models])
    for model in sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end

function getPoolSize(info, poolName)
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

function getDepthDimensionSizeName(vname, info)
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


function getOrderedOutputList(varlist, var_o)
    for var in varlist
        vname = Symbol(split(string(var), '.')[end])
        if vname === var_o
            return var
        end
    end
end

function setupOutput(info)
    out = createInitOut(info)
    outformat = info.modelRun.output.dataFormat
    datavars = map(Iterators.flatten(info.tem.variables)) do vn
        getOrderedOutputList(keys(info.modelRun.output.variables), vn)
    end
    outdims = map(datavars) do vn
        getOutDims(info, vn, info.output_root, outformat)
    end
    vnames = collect(Iterators.flatten(info.tem.variables))
    return (; init_out=out, dims=outdims, variables = vnames)
end