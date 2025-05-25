
export mlModel

"""
    mlModel(info, n_features, ::MLModelType)
Builds a Flux dense neural network model.
This function initializes a neural network model based on the provided `info` and `n_features`.

# Arguments
- `info`: The experiment information containing model options and parameters.
- `n_features`: The number of features in the input data.
- `::MLModelType`: Type dispatch for the machine learning model type.

# Supported MLModelType:
- `::FluxDenseNN`: A simple dense neural network model implemented in Flux.jl.

# Returns
The initialized machine learning model.
"""
function mlModel end

function mlModel(info, n_features, ::FluxDenseNN)
    n_params = sum(info.optimization.parameter_table.is_ml);
    n_layers = info.hybrid.ml_model.options.n_layers
    n_neurons = info.hybrid.ml_model.options.n_neurons
    ml_seed = info.hybrid.random_seed;
    @info "    Flux Dense NN with $n_features features, $n_params parameters, $n_layers hidden/inner layers and $n_neurons neurons."
    @info "    Seed: $ml_seed"
    @info "    Layers: $(n_layers)"
    @info "    Total number of parameters: $(sum(info.optimization.parameter_table.is_ml))"
    @info "    Number of parameters per layer: $(n_params / n_layers)"
    @info "    Number of neurons per layer: $(n_neurons)"
    activation_hidden = activationFunction(info.hybrid.ml_model.options, info.hybrid.ml_model.options.activation_hidden)
    activation_out = activationFunction(info.hybrid.ml_model.options, info.hybrid.ml_model.options.activation_out)
    @info "    Activation function for hidden layers: $(nameof(typeof(activation_hidden)))"
    @info "    Activation function for output layer: $(nameof(typeof(activation_out)))"
    Random.seed!(ml_seed)
    flux_model = Flux.Chain(
        Flux.Dense(n_features => n_neurons, activation_hidden),
        [Flux.Dense(n_neurons, n_neurons, activation_hidden) for _ in 1:n_layers]...,
        Flux.Dense(n_neurons => n_params, activation_out)
        )
    return flux_model
end
