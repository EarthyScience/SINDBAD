using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie


expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);

pools = info.modelStructure.states.c


"""
generateStatesInfoTable(pools)

pools = info.modelStructure.states.c
"""
function generateStatesInfoTable(pools)
    nlayers = []
    layer = []
    ntypes = []
    inits = []
    poolname = []
    parentname = []
    @show pools
    pools = Dict(pairs(pools))
    for (pool, poolInfo) in pools
        @show pool, poolInfo, typeof(poolInfo)
        if poolInfo isa Array{<:Number,1}
            lenpool = Int64(poolInfo[1])
            append!(nlayers, fill(1, lenpool))
            append!(layer, collect(1:poolInfo[1]))
            append!(ntypes, fill(poolInfo[2], lenpool))
            append!(inits, fill(poolInfo[3], lenpool))
            append!(poolname, fill(pool, lenpool))
            append!(parentname, fill(pool, lenpool))
        else
            subpools = propertynames(poolInfo)
            for (idx, p) in enumerate(poolInfo)
                lenpool = Int64(p[1])
                append!(nlayers, fill(1, lenpool))
                append!(layer, collect(1:p[1]))
                append!(ntypes, fill(p[2], lenpool))
                append!(inits, fill(p[3], lenpool))
                append!(poolname, fill(String(pool)*String(subpools[idx]), lenpool))
                append!(parentname, fill(pool, lenpool))
            end

        end
    end
    Table(; parentname, poolname, nlayers, layer, ntypes, inits)
end

poolInfo = generateStatesInfoTable(pools.pools)
# initStates = (; wSoil=[0.01], wSnow=[0.01])

# wsnowvals = info.modelStructure.states.w.pools.wSnow


# wsoilvals = info.modelStructure.states.w.pools.wSoil

# wSoil = fill(wsoilvals[end], (wsoilvals[1], wsoilvals[2]))
# wSnow = fill(wsnowvals[end], (wsnowvals[1], wsnowvals[2]))

# initStates = (; wSoil, wSnow)
# tblParams = getParameters(info.tem.models.forward, info.opti.params2opti)
