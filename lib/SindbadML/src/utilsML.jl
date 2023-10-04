export getParamsAct
export partitionBatches
export siteNameToID
export shuffleBatches
export shuffleList


function getParamsAct(pNorm, tbl_params)
    lb = oftype(tbl_params.default, tbl_params.lower)
    ub = oftype(tbl_params.default, tbl_params.upper)
    pVec = pNorm .* (ub .- lb) .+ lb
    return pVec
end

"""
`partitionBatches`(n; `batch_size=32`)
"""
function partitionBatches(n; batch_size=32)
    return partition(1:n, batch_size)
end



"""
`siteNameToID`(`site_name`, `sites_forcing`)
"""
function siteNameToID(site_name, sites_list)
    return findfirst(s -> s == site_name, sites_list)
end


"""
`shuffleBatches`(list, bs; seed=1)

    - bs :: Batch size
"""
function shuffleBatches(list, bs; seed=1)
    bs_idxs = partitionBatches(length(list); batch_size = bs)
    s_list = shuffleList(list; seed=seed)
    xbatches = [s_list[p] for p ∈ bs_idxs if length(p) == bs]
    return xbatches
end

"""
`shuffleList`(list; seed=123)
"""
function shuffleList(list; seed=123)
    Random.seed!(seed)
    rand_indxs = randperm(length(list))
    return list[rand_indxs]
end
