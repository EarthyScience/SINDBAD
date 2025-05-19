export getParamsAct
export partitionBatches
export siteNameToID
export shuffleBatches
export shuffleList

"""
    getParamsAct(x, parameter_table)

Scales `x` values in the [0,1] interval to some given lower `lo_b` and upper `up_b` bounds.

# Arguments
- `x`: vector array
- `parameter_table`: a Table with input fields `default`, `lower` and `upper` that match the `x` vector.

Returns a vector array with new values scaled into the new interval `[lower, upper]`.
"""
function getParamsAct(x, parameter_table)
    lo_b = oftype(parameter_table.initial, parameter_table.lower)
    up_b = oftype(parameter_table.initial, parameter_table.upper)
    return scaleToBounds.(x, lo_b, up_b)
end

"""
    scaleToBounds(x, lo_b, up_b)

Scales values in the [0,1] interval to some given lower `lo_b` and upper `up_b` bounds.

# Arguments
- `x`: vector array
- `lo_b`: lower bound
- `up_b`: upper bound
"""
function scaleToBounds(x, lo_b, up_b)
    return x * (up_b - lo_b) + lo_b
end


"""
    partitionBatches(n; batch_size=32)

Return an Iterator partitioning a dataset into batches.

# Arguments
- `n`: number of samples
- `batch_size`: batch size
"""
function partitionBatches(n; batch_size=32)
    return partition(1:n, batch_size)
end


"""
    siteNameToID(site_name, sites_list)

Returns the index of `site_name` in the `sites_list`

# Arguments
- `site_name`: site name
- `sites_list`: list of site names
"""
function siteNameToID(site_name, sites_list)
    return findfirst(s -> s == site_name, sites_list)
end


"""
    shuffleBatches(list, bs; seed=1)

# Arguments
- `bs`: Batch size
- `list`: an array of samples
- `seed`: Int

Returns shuffled partitioned batches.

"""
function shuffleBatches(list, bs; seed=1)
    bs_idxs = partitionBatches(length(list); batch_size = bs)
    s_list = shuffleList(list; seed=seed)
    xbatches = [s_list[p] for p in bs_idxs if length(p) == bs]
    return xbatches
end

"""
    shuffleList(list; seed=123)

# Arguments
- `list`: an array of samples
- `seed`: Int
"""
function shuffleList(list; seed=123)
    rand_indxs = randperm(MersenneTwister(seed), length(list))
    return list[rand_indxs]
end
