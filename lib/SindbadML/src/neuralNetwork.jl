export denseNN
export destructureNN

"""
    `denseNN`(`in_dim::Int`, `n_neurons::Int`, `out_dim::Int`; `extra_hlayers`=0, `activation_hidden`=Flux.relu, `activation_out`= Flux.sigmoid, seed=1618)

Inputs:
- `in_dim` :: input dimension
- `n_neurons` :: number of neurons in each hidden layer
- `out_dim` :: output dimension
- `extra_hlayers`=0 :: controls the number of extra hidden layers, default is `zero` 
- `activation_hidden`=Flux.relu :: activation function within hidden layers, default is Relu
- `activation_out`= Flux.sigmoid :: activation of output layer, default is sigmoid
- seed=1618 :: Random seed, default is ~ (1+√5)/2

Returns a `Flux.Chain` neural network.
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
    destructureNN(model; nn_opt=Optimisers.Adam())

Given a `model` returns a `flat` vector with all weights, a `re` structure of the neural network and the current `state`.

Inputs:
- model: a Flux.Chain neural network.
- nn_opt: Optimiser, the default is `Optimisers.Adam()`.

Returns: flat, re, opt_state
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end