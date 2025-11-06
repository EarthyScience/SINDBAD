<details class='jldocstring custom-block' open>
<summary><a id='SindbadML' href='#SindbadML'><span class="jlbinding">SindbadML</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadML
```


The `SindbadML` package provides the core functionality for integrating machine learning (ML) and hybrid modeling capabilities into the SINDBAD framework. It enables the use of neural networks and other ML models alongside process-based models for parameter learning, and potentially hybrid modeling, and advanced optimization.

**Purpose**

This package brings together all components required for hybrid (process-based + ML) modeling in SINDBAD, including data preparation, model construction, training routines, gradient computation, and optimizer management. It supports flexible configuration, cross-validation, and seamless integration with SINDBAD&#39;s process-based modeling workflows.

**Dependencies**
- `Distributed`: Parallel and distributed computing utilities (`nworkers`, `pmap`, `workers`, `nprocs`, `CachingPool`).
  
- `Sindbad`, `SindbadTEM`, `SindbadSetup`: Core SINDBAD modules for process-based modeling and setup.
  
- `SindbadData.YAXArrays`, `SindbadData.Zarr`, `SindbadData.AxisKeys`, `SindbadData`: Data handling, array, and cube utilities.
  
- `SindbadMetrics`: Metrics for model performance/loss evaluation.
  
- `PolyesterForwardDiff`, `Enzyme`, `Zygote`, `ForwardDiff`, `FiniteDiff`, `FiniteDifferences`: Automatic and numerical differentiation libraries for gradient-based learning. (Defaults will be Zygote and PolyesterForwardDiff for performance. All others should come as extensions.)
  
- `Flux`: Neural network layers and training utilities for ML models.
  
- `Optimisers`: Optimizers for training neural networks.
  
- `Statistics`: Statistical utilities.
  
- `ProgressMeter`: Progress bars for ML training and evaluation (`@showprogress`, `Progress`, `next!`, `progress_pmap`, `progress_map`).
  
- `PreallocationTools`: Tools for efficient memory allocation.
  
- `Base.Iterators`: Iterators for batching and repetition (`repeated`, `partition`).
  
- `Random`: Random number utilities.
  
- `JLD2`: For saving and loading model checkpoints and fold indices.
  

**Included Files**
- `utilsML.jl`: Utility functions for ML workflows.
  
- `diffCaches.jl`: Caching utilities for differentiation.
  
- `activationFunctions.jl`: Implements various activation functions, including custom and Flux-provided activations.
  
- `mlModels.jl`: Constructors and utilities for building neural network models and other ML architectures.
  
- `mlOptimizers.jl`: Functions for creating and configuring optimizers for ML training.
  
- `loss.jl`: Loss functions and utilities for evaluating model performance and computing gradients.
  
- `prepHybrid.jl`: Prepares all data structures, loss functions, and ML components required for hybrid modeling, including data splits and feature extraction.
  
- `mlGradient.jl`: Routines for computing gradients using different libraries and methods, supporting both automatic and finite difference differentiation.
  
- `mlTrain.jl`: Training routines for ML and hybrid models, including batching, checkpointing, and evaluation.
  
- `neuralNetwork.jl`: Neural network utilities and architectures.
  
- `siteLosses.jl`: Site-specific loss calculation utilities.
  
- `oneHots.jl`: One-hot encoding utilities.
  
- `loadCovariates.jl`: Functions for loading and handling covariate data.
  

**Notes**
- The package is modular and extensible, allowing users to add new ML models, optimizers, activation functions, and training methods.
  
- It is tightly integrated with the SINDBAD ecosystem, ensuring consistent data handling and reproducibility across hybrid and process-based modeling workflows.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/SindbadML.jl#L1-L42" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.JoinDenseNN-Tuple{Tuple}' href='#SindbadML.JoinDenseNN-Tuple{Tuple}'><span class="jlbinding">SindbadML.JoinDenseNN</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
JoinDenseNN(models::Tuple)
```


**Arguments:**
- models :: a tuple of models, i.e. (m1, m2)
  

**Returns:**
- all parameters as a vector or matrix (multiple samples)
  

**Example**

```julia
using SindbadML
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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/neuralNetwork.jl#L68-L95" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.activationFunction' href='#SindbadML.activationFunction'><span class="jlbinding">SindbadML.activationFunction</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
activationFunction(model_options, act::AbstractActivation)
```


Return the activation function corresponding to the specified activation type and model options.

This function dispatches on the activation type to provide the appropriate activation function for use in neural network layers. For custom activation types, relevant parameters can be passed via `model_options`.

**Arguments**
- `model_options`: A struct or NamedTuple containing model options, including parameters for custom activation functions (e.g., `k_σ` for `CustomSigmoid`).
  
- `act`: An activation type specifying the desired activation function. Supported types include:
  - `FluxRelu`: Rectified Linear Unit (ReLU) activation.
    
  - `FluxTanh`: Hyperbolic Tangent (tanh) activation.
    
  - `FluxSigmoid`: Sigmoid activation.
    
  - `CustomSigmoid`: Custom sigmoid activation with steepness parameter `k_σ`.
    
  

**Returns**
- A callable activation function suitable for use in neural network layers.
  

**Example**

```julia
act_fn = activationFunction(model_options, FluxRelu())
y = act_fn(x)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/activationFunctions.jl#L3-L26" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.denseNN-Tuple{Int64, Int64, Int64}' href='#SindbadML.denseNN-Tuple{Int64, Int64, Int64}'><span class="jlbinding">SindbadML.denseNN</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
denseNN(in_dim::Int, n_neurons::Int, out_dim::Int; extra_hlayers=0, activation_hidden=Flux.relu, activation_out= Flux.sigmoid, seed=1618)
```


**Arguments**
- `in_dim`: input dimension
  
- `n_neurons`: number of neurons in each hidden layer
  
- `out_dim`: output dimension
  
- `extra_hlayers`=0: controls the number of extra hidden layers, default is `zero` 
  
- `activation_hidden`=Flux.relu: activation function within hidden layers, default is Relu
  
- `activation_out`= Flux.sigmoid: activation of output layer, default is sigmoid
  
- `seed=1618`: Random seed, default is ~ (1+√5)/2
  

Returns a `Flux.Chain` neural network.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/neuralNetwork.jl#L7-L20" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.destructureNN-Tuple{Any}' href='#SindbadML.destructureNN-Tuple{Any}'><span class="jlbinding">SindbadML.destructureNN</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
destructureNN(model; nn_opt=Optimisers.Adam())
```


Given a `model` returns a `flat` vector with all weights, a `re` structure of the neural network and the current `state`.

**Arguments**
- `model`: a Flux.Chain neural network.
  
- `nn_opt`: Optimiser, the default is `Optimisers.Adam()`.
  

Returns:
- flat :: a flat vector with all network weights
  
- re :: an object containing the model structure, used later to `re`construct the neural network
  
- opt_state :: the state of the optimiser
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/neuralNetwork.jl#L33-L46" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.epochLossComponents-Union{Tuple{F}, Tuple{F, Vararg{Any, 5}}} where F' href='#SindbadML.epochLossComponents-Union{Tuple{F}, Tuple{F, Vararg{Any, 5}}} where F'><span class="jlbinding">SindbadML.epochLossComponents</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
epochLossComponents(loss_functions::F, loss_array_sites, loss_array_components, epoch_number, scaled_params, sites_list) where {F}
```


Compute and store the loss metrics and loss components for each site in parallel for a given training epoch.

This function evaluates the provided loss functions for each site using the current scaled parameters, and stores the resulting scalar loss metrics and loss component vectors in the corresponding arrays for the specified epoch. Parallel execution is used to accelerate computation across sites.

**Arguments**
- `loss_functions::F`: An array or KeyedArray of loss functions, one per site (where `F` is a subtype of `AbstractArray{<:Function}`).
  
- `loss_array_sites`: A matrix to store the scalar loss metric for each site and epoch (dimensions: site × epoch).
  
- `loss_array_components`: A 3D tensor to store the loss components for each site, component, and epoch (dimensions: site × component × epoch).
  
- `epoch_number`: The current epoch number (integer).
  
- `scaled_params`: A callable or array providing the scaled parameters for each site (e.g., `scaled_params(site=site_name)`).
  
- `sites_list`: List or array of site identifiers to process.
  

**Notes**
- The function uses Julia&#39;s threading (`Threads.@spawn`) to compute losses for multiple sites in parallel.
  
- Each site&#39;s loss metric and components are stored at the corresponding index for the current epoch.
  
- Designed for use within training loops to track loss evolution over epochs.
  

**Example**

```julia
epochLossComponents(loss_functions, loss_array_sites, loss_array_components, epoch, scaled_params, sites)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/loss.jl#L107-L131" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getCacheFromOutput' href='#SindbadML.getCacheFromOutput'><span class="jlbinding">SindbadML.getCacheFromOutput</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getCacheFromOutput(loc_output, ::MLGradType)
getCacheFromOutput(loc_output, ::ForwardDiffGrad)
getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)
```


Returns the appropriate Cache type based on the automatic differentiation or finite differences package being used.

**Arguments**
- `loc_output`: The local output
  
- Second argument specifies the differentiation method:
  - `ForwardDiffGrad`: Uses ForwardDiff.jl for automatic differentiation
    
  - `MLGradType`: All other libraries, e.g., FiniteDiff.jl,FiniteDifferences.jl, etc.  for gradient calculations
    
  - `PolyesterForwardDiffGrad`: Uses PolyesterForwardDiff.jl for automatic differentiation
    
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/diffCaches.jl#L16-L30" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getIndicesSplit' href='#SindbadML.getIndicesSplit'><span class="jlbinding">SindbadML.getIndicesSplit</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getIndicesSplit(info, sites, fold_type)
```


Determine the indices for training, validation, and testing site splits for hybrid (ML) modeling in SINDBAD.

This function dispatches on the `fold_type` argument to either load precomputed folds from file or to compute the splits on-the-fly based on the provided split ratios and number of folds.

**Arguments**
- `info`: The SINDBAD experiment info structure, containing hybrid modeling configuration.
  
- `sites`: Array of site identifiers (e.g., site names or indices).
  
- `fold_type`: Determines the splitting strategy. Use `LoadFoldFromFile()` to load folds from file, or `CalcFoldFromSplit()` to compute splits dynamically.
  

**Returns**
- `indices_training`: Indices of sites assigned to the training set.
  
- `indices_validation`: Indices of sites assigned to the validation set.
  
- `indices_testing`: Indices of sites assigned to the testing set.
  

**Notes**
- When using `LoadFoldFromFile`, the function loads fold indices from the file specified in `info.hybrid.fold.fold_path`.
  
- When using `CalcFoldFromSplit`, the function splits the sites according to the ratios and number of folds specified in `info.hybrid.ml_training.options`.
  
- Ensures reproducibility by using the random seed from `info.hybrid.random_seed` when shuffling sites.
  

**Example**

```julia
indices_train, indices_val, indices_test = getIndicesSplit(info, sites, info.hybrid.fold.fold_type)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/prepHybrid.jl#L3-L29" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getInnerArgs-NTuple{17, Any}' href='#SindbadML.getInnerArgs-NTuple{17, Any}'><span class="jlbinding">SindbadML.getInnerArgs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getInnerArgs(idx, grads_lib, scaled_params_batch, parameter_scaling_type, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, loc_land, tem_info, parameter_to_index, parameter_scaling_type, space_observations, cost_options, constraint_method, indices_batch, sites_batch)
```


Function to get inner arguments for the loss function.

**Arguments**
- `idx`: index batch value
  
- `grads_lib`: gradient library
  
- `scaled_params_batch`: scaled parameters batch
  
- `selected_models`: selected models
  
- `space_forcing`: forcing data location
  
- `space_spinup_forcing`: spinup forcing data location
  
- `loc_forcing_t`: forcing data time for one time step.
  
- `space_output`: output data location
  
- `loc_land`: initial land state
  
- `tem_info`: model information
  
- `parameter_to_index`: parameter to index
  
- `parameter_scaling_type`: type determining parameter scaling
  
- `loc_observations`: observation data location
  
- `cost_options`: cost options
  
- `constraint_method`: constraint method
  
- `indices_batch`: indices batch
  
- `sites_batch`: sites batch
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/siteLosses.jl#L125-L148" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getLossForSites-Union{Tuple{F}, Tuple{Any, F, Vararg{Any, 18}}} where F' href='#SindbadML.getLossForSites-Union{Tuple{F}, Tuple{Any, F, Vararg{Any, 18}}} where F'><span class="jlbinding">SindbadML.getLossForSites</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLossForSites(gradient_lib, loss_function::F, loss_array_sites, loss_array_split, epoch_number, scaled_params, sites_list, indices_sites, models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, loc_land, tem_info, parameter_to_index, parameter_scaling_type, space_observations, cost_options, constraint_method) where {F}
```


Calculates the loss for all sites. The loss is calculated using the `loss_function` function. The `loss_array_sites` and `loss_array_split` arrays are updated with the loss values. The `loss_array_sites` array stores the loss values for each site and epoch, while the `loss_array_split` array stores the loss values for each model output and epoch.

**Arguments**
- `gradient_lib`: gradient library
  
- `loss_function`: loss function
  
- `loss_array_sites`: array to store the loss values for each site and epoch
  
- `loss_array_split`: array to store the loss values for each model output and epoch
  
- `epoch_number`: epoch number
  
- `scaled_params`: scaled parameters
  
- `sites_list`: list of sites
  
- `indices_sites`: indices of sites
  
- `models`: list of models
  
- `space_forcing`: forcing data location
  
- `space_spinup_forcing`: spinup forcing data location
  
- `loc_forcing_t`: forcing data time for one time step.
  
- `space_output`: output data location
  
- `loc_land`: initial land state
  
- `tem_info`: model information
  
- `parameter_to_index`: parameter to index
  
- `space_observations`: observation data location
  
- `cost_options`: cost options
  
- `constraint_method`: constraint method
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/siteLosses.jl#L72-L97" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getLossFunctionHandles-Tuple{Any, Any, Any}' href='#SindbadML.getLossFunctionHandles-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadML.getLossFunctionHandles</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLossFunctionHandles(info, run_helpers, sites)
```


Construct loss function handles for each site for use in hybrid (ML) modeling in SINDBAD.

This function generates callable loss functions and loss component functions for each site, encapsulating all necessary arguments and configuration from the experiment `info` and runtime helpers. These handles are used during training and evaluation to compute the loss and its components for each site efficiently.

**Arguments**
- `info`: The SINDBAD experiment info structure, containing model, optimization, and hybrid configuration.
  
- `run_helpers`: Helper object returned by `prepTEM`, containing prepared model, forcing, observation, and output structures.
  
- `sites`: Array of site indices or identifiers for which to build loss functions.
  

**Returns**
- `loss_functions`: A `KeyedArray` of callable loss functions, one per site. Each function takes model parameters as input and returns the scalar loss for that site.
  
- `loss_component_functions`: A `KeyedArray` of callable functions, one per site, that return the vector of loss components (e.g., for multi-objective or constraint-based loss).
  

**Notes**
- Each loss function is closed over all required data and options for its site, including model structure, parameter indices, scaling, forcing, observations, output cache, cost options, and hybrid/optimization settings.
  
- The returned arrays are keyed by site for convenient lookup and iteration.
  

**Example**

```julia
loss_functions, loss_component_functions = getLossFunctionHandles(info, run_helpers, sites)
site_loss = loss_functions[site_index](params)
site_loss_components = loss_component_functions[site_index](params)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/prepHybrid.jl#L118-L144" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getOutputFromCache' href='#SindbadML.getOutputFromCache'><span class="jlbinding">SindbadML.getOutputFromCache</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getOutputFromCache(loc_output, _, ::MLGradType)
getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)
```


Retrieves output values from `Cache` based on the differentiation method being used.

**Arguments**
- `loc_output`: The cached output values
  
- `_` or `new_params`: Additional parameters (only used with ForwardDiff)
  
- Third argument specifies the differentiation method:
  - `MLGradType`: Returns cached output directly when using other libraries, e.g., FiniteDiff.jl, FiniteDifferences.jl, etc.
    
  - `ForwardDiffGrad`: Processes cached output with new parameters when using ForwardDiff.jl, returns `get_tmp.(loc_output, (new_params,))`
    
  - `PolyesterForwardDiffGrad`: Calls cached output with new parameters using ForwardDiff.jl
    
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/diffCaches.jl#L47-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getParamsAct-Tuple{Any, Any}' href='#SindbadML.getParamsAct-Tuple{Any, Any}'><span class="jlbinding">SindbadML.getParamsAct</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getParamsAct(x, parameter_table)
```


Scales `x` values in the [0,1] interval to some given lower `lo_b` and upper `up_b` bounds.

**Arguments**
- `x`: vector array
  
- `parameter_table`: a Table with input fields `default`, `lower` and `upper` that match the `x` vector.
  

Returns a vector array with new values scaled into the new interval `[lower, upper]`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L7-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getPullback' href='#SindbadML.getPullback'><span class="jlbinding">SindbadML.getPullback</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getPullback(flat, re, features::AbstractArray)
getPullback(flat, re, features::Tuple)
```


**Arguments:**
- flat :: weight parameters.
  
- re :: model structure (vanilla Chain Dense Layers).
  
- features ::  `n` predictors and `s` samples.
  - A vector of predictors
    
  - A matrix of predictors: `(p_n x s)`
    
  - A tuple vector of predictors: `(p1, p2)`
    
  - A tuple of matrices of predictors: `[(p1_n x s), (p2_n x s)]`
    
  

**Returns:**
- new parameters and pullback function
  

**Example**

Here we do one input features vector or matrix.

```julia
using SindbadML
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


**Example**

Here we do one multiple input features vector or matrix.

```julia
using SindbadML
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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/neuralNetwork.jl#L119-L178" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.gradientBatch!' href='#SindbadML.gradientBatch!'><span class="jlbinding">SindbadML.gradientBatch!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
gradientBatch!(grads_lib, grads_batch, chunk_size::Int, loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
gradientBatch!(grads_lib, grads_batch, gradient_options::NamedTuple, loss_functions, scaled_params_batch, sites_batch; showprog=false)
```


Compute gradients for a batch of samples in hybrid (ML) modeling in SINDBAD.

This function computes the gradients of the loss function with respect to model parameters for a batch of sites or samples, using the specified gradient library. It supports both distributed and multi-threaded execution, and can handle different gradient computation backends (e.g., `PolyesterForwardDiff`, `ForwardDiff`, `FiniteDiff`, etc.).

**Arguments**
- `grads_lib`: Gradient computation library or method. Supported types include:
  - `PolyesterForwardDiffGrad`: Uses `PolyesterForwardDiff.jl` for multi-threaded chunked gradients.
    
  - Other `MLGradType` subtypes: Use their respective backend.
    
  
- `grads_batch`: Pre-allocated array for storing batched gradients (size: n_parameters × n_samples).
  
- `chunk_size`: (Optional) Chunk size for threaded gradient computation (used by `PolyesterForwardDiffGrad`).
  
- `gradient_options`: (Optional) NamedTuple of gradient options (e.g., chunk size).
  
- `loss_f`: Loss function to be applied (for all samples).
  
- `get_inner_args`: Function to obtain inner arguments for the loss function.
  
- `input_args`: Global input arguments for the batch.
  
- `loss_functions`: Array or KeyedArray of loss functions, one per site.
  
- `scaled_params_batch`: Callable or array providing scaled parameters for each site.
  
- `sites_batch`: List or array of site identifiers for the batch.
  
- `showprog`: (Optional) If `true`, display a progress bar during computation (default: `false`).
  

**Returns**
- Updates `grads_batch` in-place with computed gradients for each sample in the batch.
  

**Notes**
- The function automatically selects between distributed (`pmap`) and multi-threaded (`Threads.@spawn`) execution depending on the backend and arguments.
  
- Designed for use within training loops for efficient batch gradient computation.
  

**Example**

```julia
gradientBatch!(grads_lib, grads_batch, (chunk_size=4,), loss_functions, scaled_params_batch, sites_batch; showprog=true)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L177-L211" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.gradientSite' href='#SindbadML.gradientSite'><span class="jlbinding">SindbadML.gradientSite</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
gradientSite(grads_lib, x_vals, chunk_size::Int, loss_f::Function, args...)
gradientSite(grads_lib, x_vals, gradient_options::NamedTuple, loss_f::Function)
gradientSite(grads_lib, x_vals::AbstractArray, gradient_options::NamedTuple, loss_f::Function)
```


Compute gradients of the loss function with respect to model parameters for a single site using the specified gradient library.

This function dispatches on the type of `grads_lib` to select the appropriate differentiation backend (e.g., `PolyesterForwardDiff`, `ForwardDiff`, `FiniteDiff`, `FiniteDifferences`, `Zygote`, or `Enzyme`). It supports both threaded and single-threaded computation, as well as chunked evaluation for memory and speed trade-offs.

**Arguments**
- `grads_lib`: Gradient computation library or method. Supported types include:
  - `PolyesterForwardDiffGrad`: Uses `PolyesterForwardDiff.jl` for multi-threaded chunked gradients.
    
  - `ForwardDiffGrad`: Uses `ForwardDiff.jl` for automatic differentiation.
    
  - `FiniteDiffGrad`: Uses `FiniteDiff.jl` for finite difference gradients.
    
  - `FiniteDifferencesGrad`: Uses `FiniteDifferences.jl` for finite difference gradients.
    
  - `ZygoteGrad`: Uses `Zygote.jl` for reverse-mode automatic differentiation.
    
  - `EnzymeGrad`: Uses `Enzyme.jl` for AD (experimental).
    
  
- `x_vals`: Parameter values for which to compute gradients.
  
- `chunk_size`: (Optional) Chunk size for threaded gradient computation (used by `PolyesterForwardDiffGrad`).
  
- `gradient_options`: (Optional) NamedTuple of gradient options (e.g., chunk size).
  
- `loss_f`: Loss function to be differentiated.
  
- `args...`: Additional arguments to be passed to the loss function.
  

**Returns**
- `∇x`: Array of gradients of the loss function with respect to `x_vals`.
  

**Notes**
- On Apple M1 systems, `PolyesterForwardDiffGrad` falls back to single-threaded `ForwardDiff` due to closure issues.
  
- The function is used internally for both site-level and batch-level gradient computation in hybrid ML training.
  

**Example**

```julia
grads = gradientSite(ForwardDiffGrad(), x_vals, (chunk_size=4,), loss_f)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L98-L132" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.gradsNaNCheck!-NTuple{4, Any}' href='#SindbadML.gradsNaNCheck!-NTuple{4, Any}'><span class="jlbinding">SindbadML.gradsNaNCheck!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
gradsNaNCheck!(grads_batch, _params_batch, sites_batch, parameter_table; show_params_for_nan=false)
```


Utility function to check if some calculated gradients were NaN (if found please double check your approach). This function will replace those NaNs with 0.0f0.

**Arguments**
- `grads_batch`: gradients array.
  
- `_params_batch`: parameters values.
  
- `sites_batch`: sites names.
  
- `parameter_table`: parameters table.
  
- `show_params_for_nan=false`: if true, it will show the parameters that caused the NaNs.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L260-L272" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.lcKAoneHotbatch-NTuple{4, Any}' href='#SindbadML.lcKAoneHotbatch-NTuple{4, Any}'><span class="jlbinding">SindbadML.lcKAoneHotbatch</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
lcKAoneHotbatch(lc_data, up_bound, lc_name, ka_labels)
```


**Arguments**
- `lc_data`: Vector array
  
- `up_bound`: last index class, the range goes from `1:up_bound`, and any case not in that range uses the `up_bound` value. For `PFT` use `17` and for `KG` `32`. 
  
- `lc_name`: land cover approach, either `KG` or `PFT`.
  
- `ka_labels`: KeyedArray labels, i.e. site names
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L97-L105" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.loadCovariates-Tuple{Any}' href='#SindbadML.loadCovariates-Tuple{Any}'><span class="jlbinding">SindbadML.loadCovariates</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loadCovariates(sites_forcing; kind="all")
```


use the `kind` argument to select different sets of covariates

**Arguments**
- sites_forcing: names of forcing sites
  
- kind: defaults to &quot;all&quot;
  

Other options
- `PFT`
  
- `KG`
  
- `KG_PFT`
  
- `PFT_ABCNOPSWB`
  
- `KG_ABCNOPSWB`
  
- `ABCNOPSWB`
  
- `veg_all`
  
- `veg`
  
- `KG_veg`
  
- `veg_ABCNOPSWB`
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/loadCovariates.jl#L3-L23" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.loadTrainedNN-Tuple{Any}' href='#SindbadML.loadTrainedNN-Tuple{Any}'><span class="jlbinding">SindbadML.loadTrainedNN</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loadTrainedNN(path_model)
```


**Arguments**
- `path_model`: path to the model.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L289-L294" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.loss-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, LossModelObsML}' href='#SindbadML.loss-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, LossModelObsML}'><span class="jlbinding">SindbadML.loss</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loss(params, models, parameter_to_index, parameter_scaling_type, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, loc_obs, cost_options, constraint_method, gradient_lib, ::LossModelObsML)
```


Calculates the scalar loss for a given site in hybrid (ML) modeling in SINDBAD.

This function computes the loss value for a given site by first calling `lossVector` to obtain the vector of loss components, and then combining them into a scalar loss using the `combineMetric` function and the specified constraint method.

**Arguments**
- `params`: Model parameters (typically output from an ML model).
  
- `models`: List of process-based models.
  
- `parameter_to_index`: Mapping from parameter names to indices.
  
- `parameter_scaling_type`: Parameter scaling configuration.
  
- `loc_forcing`: Forcing data for the site.
  
- `loc_spinup_forcing`: Spinup forcing data for the site.
  
- `loc_forcing_t`: Forcing data for a single time step.
  
- `loc_output`: Output data structure for the site.
  
- `land_init`: Initial land state.
  
- `tem_info`: Model information and configuration.
  
- `loc_obs`: Observation data for the site.
  
- `cost_options`: Cost function and metric configuration.
  
- `constraint_method`: Constraint method for combining metrics.
  
- `gradient_lib`: Gradient computation library or method.
  
- `::LossModelObsML`: Type dispatch for loss model with observations and machine learning.
  

**Returns**
- `t_loss`: Scalar loss value for the site.
  

**Notes**
- This function is used internally by higher-level training and evaluation routines.
  
- The loss is computed by aggregating the loss vector using the specified constraint method.
  

**Example**

```julia
t_loss = loss(params, models, parameter_to_index, parameter_scaling_type, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, loc_obs, cost_options, constraint_method, gradient_lib, LossModelObsML())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/loss.jl#L59-L94" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.lossSite-NTuple{14, Any}' href='#SindbadML.lossSite-NTuple{14, Any}'><span class="jlbinding">SindbadML.lossSite</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
lossSite(new_params, gradient_lib, models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, parameter_to_index, parameter_scaling_type, loc_obs, cost_options, constraint_method; optim_mode=true)
```


Function to calculate the loss for a given site. This is used for optimization, hence the `optim_mode` argument is set to `true` by default. Also, a gradient library should be set as well as new parameters to update the models. See all input arguments in the function:

**Arguments**
- `new_params`: new parameters
  
- `gradient_lib`: gradient library
  
- `models`: list of models
  
- `loc_forcing`: forcing data location
  
- `loc_spinup_forcing`: spinup forcing data location
  
- `loc_forcing_t`: forcing data time for one time step.
  
- `loc_output`: output data location
  
- `land_init`: initial land state
  
- `tem_info`: model information
  
- `parameter_to_index`: parameter to index
  
- `loc_obs`: observation data location
  
- `cost_options`: cost options
  
- `constraint_method`: constraint method
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/siteLosses.jl#L43-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.lossVector-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, LossModelObsML}' href='#SindbadML.lossVector-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, LossModelObsML}'><span class="jlbinding">SindbadML.lossVector</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
lossVector(params, models, parameter_to_index, parameter_scaling_type, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, loc_obs, cost_options, constraint_method, gradient_lib, ::LossModelObsML)
```


Calculate the loss vector for a given site in hybrid (ML) modeling in SINDBAD.

This function runs the core TEM model with the provided parameters, forcing data, initial land state, and model information, then computes the loss vector using the specified cost options and metrics. It is typically used for site-level loss evaluation during training and validation.

**Arguments**
- `params`: Model parameters (in this case, output from an ML model).
  
- `models`: List of process-based models.
  
- `parameter_to_index`: Mapping from parameter names to indices.
  
- `parameter_scaling_type`: Parameter scaling configuration.
  
- `loc_forcing`: Forcing data for the site.
  
- `loc_spinup_forcing`: Spinup forcing data for the site.
  
- `loc_forcing_t`: Forcing data for a single time step.
  
- `loc_output`: Output data structure for the site.
  
- `land_init`: Initial land state.
  
- `tem_info`: Model information and configuration.
  
- `loc_obs`: Observation data for the site.
  
- `cost_options`: Cost function and metric configuration.
  
- `constraint_method`: Constraint method for combining metrics.
  
- `gradient_lib`: Gradient computation library or method.
  
- `::LossModelObsML`: Type dispatch for loss model with observations and machine learning.
  

**Returns**
- `loss_vector`: Vector of loss components for the site.
  
- `loss_indices`: Indices corresponding to each loss component.
  

**Notes**
- This function is used internally by higher-level loss and training routines.
  
- The loss vector is typically combined into a scalar loss using `combineMetric`.
  

**Example**

```julia
loss_vec, loss_idx = lossVector(params, models, parameter_to_index, parameter_scaling_type, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, loc_obs, cost_options, constraint_method, gradient_lib, LossModelObsML())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/loss.jl#L6-L42" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.mixedGradientTraining-NTuple{7, Any}' href='#SindbadML.mixedGradientTraining-NTuple{7, Any}'><span class="jlbinding">SindbadML.mixedGradientTraining</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mixedGradientTraining(grads_lib, nn_model, train_refs, test_val_refs, loss_fargs, forward_args; n_epochs=3, optimizer=Optimisers.Adam(), path_experiment="/")
```


Training function that computes model parameters using a neural network, which are then used by process-based models (PBMs) to estimate parameter gradients. Neural network weights are updated using the product of these gradients with the neural network&#39;s Jacobian.

**Arguments**
- `grads_lib`: Library to compute PBMs parameter gradients.
  
- `nn_model`: A `Flux.Chain` neural network.
  
- `train_refs`: training data features.
  
- `test_val_refs`: test and validation data features.
  
- `loss_fargs`: functions used to calculate the loss.
  
- `forward_args`: arguments to evaluate the PBMs.
  
- `path_experiment="/"`: save model to path.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L7-L21" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.mlModel' href='#SindbadML.mlModel'><span class="jlbinding">SindbadML.mlModel</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
mlModel(info, n_features, ::MLModelType)
```


Builds a Flux dense neural network model. This function initializes a neural network model based on the provided `info` and `n_features`.

**Arguments**
- `info`: The experiment information containing model options and parameters.
  
- `n_features`: The number of features in the input data.
  
- `::MLModelType`: Type dispatch for the machine learning model type.
  

**Supported MLModelType:**
- `::FluxDenseNN`: A simple dense neural network model implemented in Flux.jl.
  

**Returns**

The initialized machine learning model.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlModels.jl#L4-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.mlOptimizer' href='#SindbadML.mlOptimizer'><span class="jlbinding">SindbadML.mlOptimizer</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
mlOptimizer(optimizer_options, ::MLOptimizerType)
```


Create a ML optimizer from the given options and type. The optimizer is created using the given options and type. The options are passed to the constructor of the optimizer.

**Arguments:**
- `optimizer_options`: A dictionary or NamedTuple containing options for the optimizer.
  
- `::MLOptimizerType`: The type used to determine which optimizer to create. Supported types include:
  - `OptimisersAdam`: For Adam optimizer.
    
  - `OptimisersDescent`: For Descent optimizer.
    
  

.

**Returns:**
- A ML optimizer object that can be used to optimize machine learning models.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlOptimizers.jl#L3-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.oneHotPFT-Tuple{Any, Any, Any}' href='#SindbadML.oneHotPFT-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadML.oneHotPFT</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
oneHotPFT(pft, up_bound, veg_class)
```


**Arguments**
- `pft`: (Plant Functional Type). Any entry not in 1:17 would be set to the last index, this includes NaN!  Last index is water/NaN
  
- `up_bound`: last index class, the range goes from `1:up_bound`, and any case not in that range uses the `up_bound` value. For `PFT` use `17`. 
  
- `veg_class`: `true` or `false`.
  

Returns a vector.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L75-L84" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.partitionBatches-Tuple{Any}' href='#SindbadML.partitionBatches-Tuple{Any}'><span class="jlbinding">SindbadML.partitionBatches</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
partitionBatches(n; batch_size=32)
```


Return an Iterator partitioning a dataset into batches.

**Arguments**
- `n`: number of samples
  
- `batch_size`: batch size
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L39-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.prepHybrid-Tuple{Any, Any, Any, MLTrainingType}' href='#SindbadML.prepHybrid-Tuple{Any, Any, Any, MLTrainingType}'><span class="jlbinding">SindbadML.prepHybrid</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
prepHybrid(forcing, observations, info, ::MLTrainingType)
```


Prepare all data structures, loss functions, and machine learning components required for hybrid (process-based + machine learning) modeling in SINDBAD.

This function orchestrates the setup for hybrid modeling by:
- Initializing model helpers and runtime structures.
  
- Building loss function handles for each site.
  
- Splitting sites into training, validation, and testing sets according to the hybrid configuration.
  
- Loading covariate features for all sites.
  
- Building the machine learning model as specified in the configuration.
  
- Preparing arrays for storing losses and loss components during training and evaluation.
  
- Initializing the optimizer for ML training.
  
- Collecting all relevant metadata and configuration into a single `hybrid_helpers` NamedTuple for downstream training routines.
  

**Arguments**
- `forcing`: Forcing data structure as required by the process-based model.
  
- `observations`: Observational data structure.
  
- `info`: The SINDBAD experiment info structure, containing all configuration and runtime options.
  
- `::MLTrainingType`: Type specifying the ML training method to use (e.g., `MixedGradient`).
  

**Returns**
- `hybrid_helpers`: A NamedTuple containing all prepared data, models, loss functions, indices, features, optimizers, and arrays needed for hybrid ML training and evaluation.
  

**Fields of `hybrid_helpers`**
- `run_helpers`: Output of `prepTEM`, containing prepared model, forcing, observation, and output structures.
  
- `sites`: NamedTuple with `training`, `validation`, and `testing` site arrays.
  
- `indices`: NamedTuple with indices for `training`, `validation`, and `testing` sites.
  
- `features`: NamedTuple with `n_features` and `data` (covariate features for all sites).
  
- `ml_model`: The machine learning model instance (e.g., a Flux neural network).
  
- `options`: The `info.hybrid` configuration NamedTuple.
  
- `checkpoint_path`: Path for saving checkpoints during training.
  
- `parameter_table`: Parameter table from `info.optimization`.
  
- `loss_functions`: KeyedArray of callable loss functions, one per site.
  
- `loss_component_functions`: KeyedArray of callable loss component functions, one per site.
  
- `training_optimizer`: The optimizer object for ML training.
  
- `loss_array`: NamedTuple of arrays to store scalar losses for training, validation, and testing.
  
- `loss_array_components`: NamedTuple of arrays to store loss components for training, validation, and testing.
  
- `metadata_global`: Global metadata from the output configuration.
  

**Notes**
- This function is typically called once at the start of a hybrid modeling experiment to set up all necessary components.
  
- The returned `hybrid_helpers` is designed to be passed directly to training routines such as `trainML`.
  

**Example**

```julia
hybrid_helpers = prepHybrid(forcing, observations, info, MixedGradient())
trainML(hybrid_helpers, MixedGradient())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/prepHybrid.jl#L168-L217" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.shuffleBatches-Tuple{Any, Any}' href='#SindbadML.shuffleBatches-Tuple{Any, Any}'><span class="jlbinding">SindbadML.shuffleBatches</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
shuffleBatches(list, bs; seed=1)
```


**Arguments**
- `bs`: Batch size
  
- `list`: an array of samples
  
- `seed`: Int
  

Returns shuffled partitioned batches.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L67-L77" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.shuffleList-Tuple{Any}' href='#SindbadML.shuffleList-Tuple{Any}'><span class="jlbinding">SindbadML.shuffleList</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
shuffleList(list; seed=123)
```


**Arguments**
- `list`: an array of samples
  
- `seed`: Int
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L85-L91" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.siteNameToID-Tuple{Any, Any}' href='#SindbadML.siteNameToID-Tuple{Any, Any}'><span class="jlbinding">SindbadML.siteNameToID</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
siteNameToID(site_name, sites_list)
```


Returns the index of `site_name` in the `sites_list`

**Arguments**
- `site_name`: site name
  
- `sites_list`: list of site names
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L53-L61" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.toClass-Tuple{Number}' href='#SindbadML.toClass-Tuple{Number}'><span class="jlbinding">SindbadML.toClass</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
toClass(x::Number; vegetation_rules)
```


**Arguments**
- `x`: a key `(Number)` from `vegetation_rules`
  
- `vegetation_rules`
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L34-L40" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.trainML-Tuple{Any, MixedGradient}' href='#SindbadML.trainML-Tuple{Any, MixedGradient}'><span class="jlbinding">SindbadML.trainML</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
trainML(hybrid_helpers, ::MLTrainingType)
```


Train a machine learning (ML) or hybrid model in SINDBAD using the specified training method.

This function performs the training loop for the ML model, handling batching, gradient computation, optimizer updates, loss calculation, and checkpointing. It supports hybrid modeling workflows where ML-derived parameters are used in process-based models, and is designed to work with the data structures prepared by `prepHybrid`.

**Arguments**
- `hybrid_helpers`: NamedTuple containing all prepared data, models, loss functions, indices, features, optimizers, and arrays needed for ML training and evaluation (as returned by `prepHybrid`).
  
- `::MLTrainingType`: Type specifying the ML training method to use (e.g., `MixedGradient`).
  

**Workflow**
- Iterates over epochs and batches of training sites.
  
- For each batch:
  - Extracts features and computes model parameters.
    
  - Computes gradients using the specified gradient method.
    
  - Checks for NaNs in gradients and replaces them if needed.
    
  - Updates model parameters using the optimizer.
    
  
- After each epoch:
  - Computes and stores losses and loss components for training, validation, and testing sets.
    
  - Saves model checkpoints and loss arrays to disk if a checkpoint path is specified.
    
  

**Notes**
- The function is extensible to support different training strategies via dispatch on `MLTrainingType`.
  
- Designed for use with hybrid modeling, where ML models provide parameters to process-based models.
  
- Checkpointing enables resuming or analyzing training progress.
  

**Example**

```julia
hybrid_helpers = prepHybrid(forcing, observations, info, MixedGradient())
trainML(hybrid_helpers, MixedGradient())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlTrain.jl#L3-L35" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegKAoneHotbatch-Tuple{Any, Any}' href='#SindbadML.vegKAoneHotbatch-Tuple{Any, Any}'><span class="jlbinding">SindbadML.vegKAoneHotbatch</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegKAoneHotbatch(pft_data, ka_labels)
```


**Arguments**
- `pft_data`: Vector array
  
- `ka_labels`: KeyedArray labels, i.e. site names
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L117-L123" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegOneHot-Tuple{Any}' href='#SindbadML.vegOneHot-Tuple{Any}'><span class="jlbinding">SindbadML.vegOneHot</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegOneHot(v_class; vegetation_labels)
```


**Arguments**
- `v_class`: get it by doing `toClass(x; vegetation_rules)`.
  
- `vegetation_labels`: see them by typing `vegetation_labels`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L63-L69" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegOneHotbatch-Tuple{Any}' href='#SindbadML.vegOneHotbatch-Tuple{Any}'><span class="jlbinding">SindbadML.vegOneHotbatch</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegOneHotbatch(veg_classes; vegetation_labels)
```


**Arguments**
- veg_classes: get these from `toClass.([x1, x2,...])`
  
- vegetation_labels: see them by typing `vegetation_labels`
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/oneHots.jl#L52-L58" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.batchShuffler-Tuple{Any, Any, Any}' href='#SindbadML.batchShuffler-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadML.batchShuffler</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
batchShuffler(x_forcings, ids_forcings, batch_size; bs_seed=1456)
```


Shuffles the batches of forcings and their corresponding indices.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/mlGradient.jl#L85-L89" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getLoss-NTuple{10, Any}' href='#SindbadML.getLoss-NTuple{10, Any}'><span class="jlbinding">SindbadML.getLoss</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getLoss(models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, loc_obs, cost_options, constraint_method; optim_mode=true)
```


Calculates the loss for a given site. At this stage model parameters should had been set. The loss is calculated using the `metricVector` and `combineMetric` functions. The `metricVector` function calculates the loss for each model output and the `combineMetric` function combines the losses into a single value.

**Arguments**
- `models`: list of models
  
- `loc_forcing`: forcing data location
  
- `loc_spinup_forcing`: spinup forcing data location
  
- `loc_forcing_t`: forcing data time for one time step.
  
- `loc_output`: output data location
  
- `land_init`: initial land state
  
- `tem_info`: model information
  
- `loc_obs`: observation data location
  
- `cost_options`: cost options
  
- `constraint_method`: constraint method
  

The optional argument `optim_mode` is used to return the loss value only when set to `true`. Otherwise, it returns the loss value, the loss vector, and the loss indices.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/siteLosses.jl#L5-L23" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getNFolds-NTuple{6, Any}' href='#SindbadML.getNFolds-NTuple{6, Any}'><span class="jlbinding">SindbadML.getNFolds</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getNFolds(sites, train_ratio, val_ratio, test_ratio, n_folds, batch_size; seed=1234)
```


Partition a list of sites into training, validation, and testing sets for k-fold cross-validation in hybrid (ML) modeling.

This function shuffles the input `sites` array using the provided random `seed` for reproducibility, then splits the sites into `n_folds` folds. It computes the number of sites for each partition based on the provided ratios, ensuring the training set size is a multiple of `batch_size`. The function returns the indices for training, validation, and testing sets, as well as the full list of folds.

**Arguments**
- `sites`: Array of site identifiers (e.g., site names or indices).
  
- `train_ratio`: Fraction of sites to assign to the training set.
  
- `val_ratio`: Fraction of sites to assign to the validation set.
  
- `test_ratio`: Fraction of sites to assign to the testing set.
  
- `n_folds`: Number of folds for cross-validation.
  
- `batch_size`: Batch size for training; training set size will be rounded down to a multiple of this value.
  
- `seed`: (Optional) Random seed for reproducibility (default: 1234).
  

**Returns**
- `train_indices`: Array of sites assigned to the training set.
  
- `val_indices`: Array of sites assigned to the validation set.
  
- `test_indices`: Array of sites assigned to the testing set.
  
- `folds`: Vector of arrays, each containing the sites for one fold.
  

**Notes**
- The sum of `train_ratio`, `val_ratio`, and `test_ratio` must be approximately 1.0.
  
- The returned `folds` can be used for further cross-validation or analysis.
  

**Example**

```julia
train_indices, val_indices, test_indices, folds = getNFolds(sites, 0.7, 0.15, 0.15, 5, 32; seed=42)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/prepHybrid.jl#L56-L86" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.scaleToBounds-Tuple{Any, Any, Any}' href='#SindbadML.scaleToBounds-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadML.scaleToBounds</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
scaleToBounds(x, lo_b, up_b)
```


Scales values in the [0,1] interval to some given lower `lo_b` and upper `up_b` bounds.

**Arguments**
- `x`: vector array
  
- `lo_b`: lower bound
  
- `up_b`: upper bound
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadML/src/utilsML.jl#L24-L33" target="_blank" rel="noreferrer">source</a></Badge>

</details>

