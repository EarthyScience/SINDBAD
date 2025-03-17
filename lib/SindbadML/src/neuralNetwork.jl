export denseNN
export destructureNN
export getPullback
export JoinDenseNN
# export SplitNN

"""
    denseNN(in_dim::Int, n_neurons::Int, out_dim::Int; extra_hlayers=0, activation_hidden=Flux.relu, activation_out= Flux.sigmoid, seed=1618)

# Arguments
- `in_dim`: input dimension
- `n_neurons`: number of neurons in each hidden layer
- `out_dim`: output dimension
- `extra_hlayers`=0: controls the number of extra hidden layers, default is `zero` 
- `activation_hidden`=Flux.relu: activation function within hidden layers, default is Relu
- `activation_out`= Flux.sigmoid: activation of output layer, default is sigmoid
- `seed=1618`: Random seed, default is ~ (1+√5)/2

Returns a `Flux.Chain` neural network.
"""
function denseNN(in_dim::Int, n_neurons::Int, out_dim::Int;
    extra_hlayers=0,
    activation_hidden=Flux.relu,
    activation_out=Flux.sigmoid,
    seed=1618)

    Random.seed!(seed)
    return Flux.Chain(Flux.Dense(in_dim => n_neurons, activation_hidden),
        [Flux.Dense(n_neurons, n_neurons, activation_hidden) for _ in 0:(extra_hlayers-1)]...,
        Flux.Dense(n_neurons => out_dim, activation_out))
end

"""
    destructureNN(model; nn_opt=Optimisers.Adam())

Given a `model` returns a `flat` vector with all weights, a `re` structure of the neural network and the current `state`.

# Arguments
- `model`: a Flux.Chain neural network.
- `nn_opt`: Optimiser, the default is `Optimisers.Adam()`.

Returns:
- flat :: a flat vector with all network weights
- re :: an object containing the model structure, used later to `re`construct the neural network
- opt_state :: the state of the optimiser
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

# Custom Join layers
# from
# https://fluxml.ai/Flux.jl/stable/tutorials/custom_layers/

struct Join{T, F}
    combine::F
    paths::T
  end
# allow Join(op, m1, m2, ...) as a constructor
Join(combine, paths...) = Join(combine, paths)
Flux.@layer Join

(mj::Join)(xs::Tuple) = mj.combine(map((f, x) -> f(x), mj.paths, xs)...)
(mj::Join)(xs...) = mj(xs)

"""
    JoinDenseNN(models::Tuple)

# Arguments:
- models :: a tuple of models, i.e. (m1, m2)

# Returns:
- all parameters as a vector or matrix (multiple samples)

# EXAMPLE:
```julia
using Flux
using Random
Random.seed!(123)

m_big = Chain(Dense(4 => 5, relu), Dense(5 => 3), Flux.sigmoid)
m_eta = Dense(1=>1, Flux.sigmoid)

x_big_a = rand(Float32, 4, 10)
x_small_a1 = rand(Float32, 1, 10)
x_small_a2 = rand(Float32, 1, 10)

model = JoinDenseNN((m_big, m_eta))
model((x_big_a, x_small_a2))
```
"""
function JoinDenseNN(models::Tuple)
    return Chain(Join(vcat, models...))
end

# ? multiple outputs and one input
# We would also like to have multiple outputs, so that different predictors can be evaluated independently in the loss function.
# from
# https://fluxml.ai/Flux.jl/stable/tutorials/custom_layers/#Multiple-outputs:-a-custom-Split-layer

# custom split layer
struct SplitNN{T}
    paths::T
end
  
SplitNN(paths...) = SplitNN(paths)
  
Flux.@layer SplitNN
  
(m::SplitNN)(x::AbstractArray) = map(f -> f(x), m.paths)


# Define pullbacks for single and multi inputs

"""
    getPullback(flat, re, features::AbstractArray)
    getPullback(flat, re, features::Tuple)

# Arguments:
- flat :: weight parameters.
- re :: model structure (vanilla Chain Dense Layers).
- features ::  `n` predictors and `s` samples.
    - A vector of predictors
    - A matrix of predictors: `(p_n x s)`
    - A tuple vector of predictors: `(p1, p2)`
    - A tuple of matrices of predictors: `[(p1_n x s), (p2_n x s)]`

# Returns:
- new parameters and pullback function

# EXAMPLE: One input
```julia
using Flux
# model
m = Chain(Dense(4 => 5, relu), Dense(5 => 3), Flux.sigmoid)
# features
_feat = rand(Float32, 4)
# apply
flat, re = destructureNN(m)
# Zygote
new_params, pullback_func = getPullback(flat, re, _feat)
# ? or
_feat_ns = rand(Float32, 4, 3) # `n` predictors and `s` samples.
new_params, pullback_func = getPullback(flat, re, _feat_ns)
```

# EXAMPLE: Multiple inputs
```julia
using Flux
# model
m1 = Chain(Dense(4 => 5, relu), Dense(5 => 3), Flux.sigmoid)
m2 = Dense(2=>1, Flux.sigmoid)
combo_ms = JoinDenseNN((m1, m2))
# features
_feat1 = rand(Float32, 4)
_feat2 = rand(Float32, 2)
# apply
flat, re = destructureNN(combo_ms)
# Zygote
new_params, pullback_func = getPullback(flat, re, (_feat1, _feat2))
# ? or with multiple samples
_feat1_ns = rand(Float32, 4, 3) # `n` predictors and `s` samples.
_feat2_ns = rand(Float32, 2, 3) # `n` predictors and `s` samples.
new_params, pullback_func = getPullback(flat, re, (_feat1_ns, _feat2_ns))
```
"""
function getPullback end

function getPullback(flat, re, features::AbstractArray)
    new_params, pullback_func = Zygote.pullback(p -> re(p)(features), flat)
    return new_params, pullback_func
end

function getPullback(flat, re, features::Tuple)
    new_params, pullback_func = Zygote.pullback(p -> re(p)(features), flat)
    return new_params, pullback_func
end