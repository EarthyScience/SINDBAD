export DenseNN
export DenseFlattened

"""
`DenseNN`(`in_dim::Int`, `n_neurons::Int`, `out_dim::Int`;
    `extra_hlayers`=0, `activation_hidden`=Flux.relu, `activation_out`= Flux.sigmoid, seed=1618)

    - `in_dim` :: input dimension
    - `n_neurons` :: number of neurons in each hidden layer
    - `out_dim` :: output dimension
    - `extra_hlayers`=0 :: controls the number of extra hidden layers, default is `zero` 
    - `activation_hidden`=Flux.relu :: activation function within hidden layers, default is Relu
    - `activation_out`= Flux.sigmoid :: activation of output layer, default is sigmoid
    - seed=1618 :: Random seed, default is ~ (1+√5)/2

"""
function DenseNN(in_dim::Int, n_neurons::Int, out_dim::Int;
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
DenseFlattened(dense_nn::Flux.Chain; opt_nn=Optimisers.Adam())

- Destructure and flattening of a Dense neural network architecture.

Inputs:

    - dense_nn :: a Flux.Chain neural network
    - opt_nn :: Optimiser, default is Adam

Outputs:
    - flat :: a flat vector with all network weigths
    - re :: an object containg the model structure, used later to `re`construct the neural network
    - opt_state :: the state of the optimiser

"""
function DenseFlattened(dense_nn::Flux.Chain; opt_nn=Optimisers.Adam())
    flat, re = Optimisers.destructure(dense_nn)
    opt_state = Optimisers.setup(opt_nn, flat)
    return flat, re, opt_state
end