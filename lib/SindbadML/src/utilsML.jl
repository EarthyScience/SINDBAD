export denseNN
export denseFlattened
export destructureNN
export getParamsAct
export partitionBatches
export siteNameToID
export shuffleBatches
export shuffleList
export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad

struct FiniteDifferencesGrad end
struct FiniteDiffGrad end
struct ForwardDiffGrad end

"""
`denseNN`(`in_dim::Int`, `n_neurons::Int`, `out_dim::Int`;
    `extra_hlayers`=0, `activation_hidden`=Flux.relu, `activation_out`= Flux.sigmoid, seed=1618)

    - `in_dim` :: input dimension
    - `n_neurons` :: number of neurons in each hidden layer
    - `out_dim` :: output dimension
    - `extra_hlayers`=0 :: controls the number of extra hidden layers, default is `zero` 
    - `activation_hidden`=Flux.relu :: activation function within hidden layers, default is Relu
    - `activation_out`= Flux.sigmoid :: activation of output layer, default is sigmoid
    - seed=1618 :: Random seed, default is ~ (1+√5)/2

"""
function denseNN(in_dim::Int, n_neurons::Int, out_dim::Int;
    extra_hlayers=0,
    activation_hidden =Flux.relu,
    activation_out= Flux.sigmoid,
    seed=1618)

    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(in_dim => n_neurons, activation_hidden),
        [Flux.Dense(n_neurons, n_neurons, activation_hidden) for _ ∈ 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => out_dim, activation_out))
end

"""
denseFlattened(dense_nn::Flux.Chain; opt_nn=Optimisers.Adam())

- Destructure and flattening of a Dense neural network architecture.

Inputs:

    - dense_nn :: a Flux.Chain neural network
    - opt_nn :: Optimiser, default is Adam

Outputs:
    - flat :: a flat vector with all network weigths
    - re :: an object containg the model structure, used later to `re`construct the neural network
    - opt_state :: the state of the optimiser

"""
function denseFlattened(dense_nn::Flux.Chain; opt_nn=Optimisers.Adam())
    flat, re = Optimisers.destructure(dense_nn)
    opt_state = Optimisers.setup(opt_nn, flat)
    return flat, re, opt_state
end


"""
    destructureNN(model; nn_opt=Optimisers.Adam())
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end


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
    # Random.seed!(seed)
    rand_indxs = randperm(MersenneTwister(seed), length(list))
    return list[rand_indxs]
end
