function checkModelForcingExists(info, forcingVariables)
    println("Not done")
end

function checkSelectedModels(fullModels, selModels)
    # consistency check for selected model structure
    for sm in selModels
        if sm ∉ fullModels
            println(sm, "is not a valid model from fullModels check model structure") # should throw error
            return false
        end
    end
    return true
end

function getSelectedOrderedModels(fullModels, selModels)
    if checkSelectedModels(fullModels, selModels)
        selModelsOrdered = []
        for msm in fullModels
            if msm in selModels
                push!(selModelsOrdered, msm)
            end
        end
        return selModelsOrdered
    end
end

function getSelectedApproaches(info, selModelsOrdered)
    sel_appr_forward = ()
    sel_appr_spinup = ()
    println(selModelsOrdered)
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.apprName
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getfield(Sinbad.Models, Symbol(sel_approach))()
        sel_appr_forward = (sel_appr_forward..., sel_approach_func)
        if modInfo.use4spinup == true
            sel_appr_spinup = (sel_appr_spinup..., sel_approach_func)
        end
    end
    # @set info.tem.models.forward = sel_appr_forward
    # @set info.tem.models.spinup = sel_appr_spinup
    info=(; info..., tem=(; models = (; forward = sel_appr_forward, spinup = sel_appr_spinup)));
    return info
end

"""
generateStatesInfoTable(pools)

pools = info.modelStructure.states.c
"""
function generateStatesInfoTable(info)
    elements = keys(info.modelStructure.states)
    for element in elements
        poolData = getfield(getfield(info.modelStructure.states, element), Symbol("pools"))
        nlayers = []
        layer = []
        ntypes = []
        inits = []
        subPoolName = []
        mainPoolName = []
        mainPools = Symbol.(getfield(getfield(info.modelStructure.states, element), Symbol("order")))
        # mainPools = Symbol.(pools)
        # poolData = OrderedDict(pairs(poolData))
        for mainPool in mainPools
            poolInfo = getproperty(poolData, mainPool)
            # mainPool = mainPools[index]
            # @show mainPool, poolInfo, typeof(poolInfo)
            if poolInfo isa Array{<:Number,1}
                lenpool = Int64(poolInfo[1])
                append!(nlayers, fill(1, lenpool))
                append!(layer, collect(1:poolInfo[1]))
                append!(ntypes, fill(poolInfo[2], lenpool))
                append!(inits, fill(poolInfo[3], lenpool))
                append!(subPoolName, fill(mainPool, lenpool))
                append!(mainPoolName, fill(mainPool, lenpool))
            else
                subpools = propertynames(poolInfo)
                for (idx, p) in enumerate(poolInfo)
                    lenpool = Int64(p[1])
                    append!(nlayers, fill(1, lenpool))
                    append!(layer, collect(1:p[1]))
                    append!(ntypes, fill(p[2], lenpool))
                    append!(inits, fill(p[3], lenpool))
                    append!(subPoolName, fill(Symbol(String(mainPool)*String(subpools[idx])), lenpool))
                    append!(mainPoolName, fill(mainPool, lenpool))
                end
            end
        end
        flags = zeros(length(mainPoolName))
        for mainPool in mainPools
            # out = (; out..., fluxes = (; out.fluxes..., roSat))
            # tmp = (; tmp..., mainPool = (;))
            zix=Int[]
            initValues=Float64[]
            components=Symbol[]
            flags = zeros(Int, length(mainPoolName))
            nZix=0
            for (ind, par) in enumerate(mainPoolName)
                if par == mainPool
                    push!(zix, ind)
                    push!(components, subPoolName[ind])
                    push!(initValues, inits[ind])
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            @show mainPool, flags, zix, nZix, components, initValues
        end
        uniqueSubPools = Set(subPoolName)
        for subPool in uniqueSubPools
            zix=Int[]
            initValues=Float64[]
            components=Symbol[]
            nZix=0
            flags = zeros(Int, length(mainPoolName))
            for (ind, par) in enumerate(subPoolName)
                if par == subPool
                    push!(initValues, inits[ind])
                    push!(components, subPoolName[ind])
                    push!(zix, ind)
                    flags[ind] = 1
                    nZix = nZix + 1
                end
            end
            @show subPool, flags, zix, nZix, components, initValues
        end
        combinePools = (getfield(getfield(info.modelStructure.states, element), Symbol("combine")))
        doCombine = combinePools[1]
        if doCombine
            combinedPoolName = Symbol.(combinePools[2])
            create = [combinedPoolName]
            components=Set(Symbol.(subPoolName))
            initValues = Float64.(inits)
            zix = 1:1:length(mainPoolName) |> collect
            flags =ones(Int, length(mainPoolName))
            nZix = length(mainPoolName)
            @show combinedPoolName, flags, zix, nZix, components, initValues
        else
            create = Symbol.(subPoolName)
        end
        println("------------------")
    end
    return info
end

function setupModel!(info)
    info = generateStatesInfoTable(info)
    selModels = propertynames(info.modelStructure.models)
    # corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
    # info=(; info..., paths=(coreTEM = corePath));
    # include(corePath)
    fullModels = propertynames(getEcosystem())
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    info = getSelectedApproaches(info, selected_models)
    return info
end
