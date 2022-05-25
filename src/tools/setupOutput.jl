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

function layersize(vname, pools)
    if vname in keys(pools.water.zix)
        length(pools.water.zix[vname])
    elseif vname in keys(pools.carbon.zix)
        length(pools.carbon.zix[vname])
    else
        1
    end
end
function getOutDims(info, vname, outpath, outformat)
    ls = layersize(vname, info.tem.pools)
    if ls > 1
        OutDims("Time", RangeAxis("$(vname)_idx", 1:ls), path=joinpath(outpath, "$(vname)$(outformat)"), overwrite=true)
    else
        OutDims("Time", path=joinpath(outpath, "$(vname)$(outformat)"), overwrite=true)
    end
end

function setupOutput(info)
    out = createInitOut(info)
    outpath = joinpath(@__DIR__(), info.modelRun.output.dirPath)
    outformat = info.modelRun.output.dataFormat
    outdims = map(Iterators.flatten(info.tem.variables)) do vn
        getOutDims(info, vn, outpath, outformat)
    end
    return (; init_out=out, dims=outdims)
end