export shuffle_list
export bs_iter
export batch_shuffle

"""
`shuffle_list`(list; seed=123)
"""
function shuffle_list(list; seed=123)
    Random.seed!(seed)
    rand_indxs = randperm(length(list))
    return list[rand_indxs]
end

"""
`bs_iter`(n; `batch_size=32`)
"""
function bs_iter(n; batch_size=32)
    return partition(1:n, batch_size)
end

"""
`batch_shuffle`(list, bs; seed=1)

    - bs :: Batch size
"""
function batch_shuffle(list, bs; seed=1)
    bs_idxs = bs_iter(length(list); batch_size = bs)
    s_list = shuffle_list(list; seed=seed)
    xbatches = [s_list[p] for p ∈ bs_idxs if length(p) == bs]
    return xbatches
end


