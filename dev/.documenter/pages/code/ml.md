<details class='jldocstring custom-block' open>
<summary><a id='SindbadML' href='#SindbadML'><span class="jlbinding">SindbadML</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadML
```


This package provides the tools to train neural networks to predict model parameters from `process-based models (PBMs)` using automatic differentiation and finite differences. It also includes functions to train PBMs using a mixed gradient approach to optimize the neural network weights and the PBM parameters simultaneously.

::: danger

This package is still under development and is not yet ready for production use.

:::

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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getCacheFromOutput' href='#SindbadML.getCacheFromOutput'><span class="jlbinding">SindbadML.getCacheFromOutput</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getCacheFromOutput(loc_output, ::GradType)
getCacheFromOutput(loc_output, ::ForwardDiffGrad)
getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)
```


Returns the appropriate Cache type based on the automatic differentiation or finite differences package being used.

**Arguments**
- `loc_output`: The local output
  
- Second argument specifies the differentiation method:
  - `ForwardDiffGrad`: Uses ForwardDiff.jl for automatic differentiation
    
  - `GradType`: All other libraries, e.g., FiniteDiff.jl,FiniteDifferences.jl, etc.  for gradient calculations
    
  - `PolyesterForwardDiffGrad`: Uses PolyesterForwardDiff.jl for automatic differentiation
    
  

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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.getOutputFromCache' href='#SindbadML.getOutputFromCache'><span class="jlbinding">SindbadML.getOutputFromCache</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getOutputFromCache(loc_output, _, ::GradType)
getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)
```


Retrieves output values from `Cache` based on the differentiation method being used.

**Arguments**
- `loc_output`: The cached output values
  
- `_` or `new_params`: Additional parameters (only used with ForwardDiff)
  
- Third argument specifies the differentiation method:
  - `GradType`: Returns cached output directly when using other libraries, e.g., FiniteDiff.jl, FiniteDifferences.jl, etc.
    
  - `ForwardDiffGrad`: Processes cached output with new parameters when using ForwardDiff.jl, returns `get_tmp.(loc_output, (new_params,))`
    
  - `PolyesterForwardDiffGrad`: Calls cached output with new parameters using ForwardDiff.jl
    
  

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


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.gradientBatch!' href='#SindbadML.gradientBatch!'><span class="jlbinding">SindbadML.gradientBatch!</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
gradientBatch!(grads_lib, dx_batch, chunk_size::Int, loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
```


**Computes gradients for a batch of samples.**

**Arguments**
- `grads_lib`: 
  - PolyesterForwardDiffGrad: uses PolyesterForwardDiff.jl for gradients computation.
    
  - GradType: For all the other package based gradients.
    
  
- `dx_batch`: pre-allocated array for batched gradients.
  
- `chunk_size`: Int, chunk size for PolyesterForwardDiff&#39;s threads.
  
- `loss_f`: loss function to be applied.
  
- `get_inner_args`: function to obtain inner values of loss function.
  
- `input_args`: global input arguments.
  

**Returns:**

A `n x m` matrix for `n parameters gradients` and `m` samples.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.gradientSite' href='#SindbadML.gradientSite'><span class="jlbinding">SindbadML.gradientSite</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
gradientSite(grads_lib, x_vals, chunk_size::Int, loss::F, args...)
```


Computes gradients using different libraries for a site

**Arguments**
- `grads_lib`:
  - PolyesterForwardDiffGrad: using `PolyesterForwardDiff.jl` for multi-threaded chunk splits. The optimal speed is ideally achieved with `one thread` when `chunk_size=1` and `n-threads` for `n` parameters. However, a good compromise between memory allocations and speed could be to set `chunk_size=3` and use `n-threads` for `2n parameters`. !!! warning
    
  For M1 systems we default to ForwardDiff.gradient! single-threaded. And we let the `GradientConfig` constructor to automatically select the appropriate `chunk_size`.
  - ForwardDiffGrad: uses ForwardDiff.jl for gradients computation.
    
  - FiniteDiffGrad: uses FiniteDiff.jl for gradients computation.
    
  - FiniteDifferencesGrad: uses FiniteDifferences.jl for gradients computation.
    
  
- `x_vals`: parameters values.
  
- `chunk_size`: Int, chunk size for PolyesterForwardDiff&#39;s threads.
  
- `loss_f`: loss function to be applied.
  
- `args...`: additional arguments for the loss function.
  

Returns: a `∇x` array with all parameter&#39;s gradients.

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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.loadTrainedNN-Tuple{Any}' href='#SindbadML.loadTrainedNN-Tuple{Any}'><span class="jlbinding">SindbadML.loadTrainedNN</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loadTrainedNN(path_model)
```


**Arguments**
- `path_model`: path to the model.
  

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

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.shuffleList-Tuple{Any}' href='#SindbadML.shuffleList-Tuple{Any}'><span class="jlbinding">SindbadML.shuffleList</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
shuffleList(list; seed=123)
```


**Arguments**
- `list`: an array of samples
  
- `seed`: Int
  

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
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.toClass-Tuple{Number}' href='#SindbadML.toClass-Tuple{Number}'><span class="jlbinding">SindbadML.toClass</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
toClass(x::Number; vegetation_rules)
```


**Arguments**
- `x`: a key `(Number)` from `vegetation_rules`
  
- `vegetation_rules`
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegKAoneHotbatch-Tuple{Any, Any}' href='#SindbadML.vegKAoneHotbatch-Tuple{Any, Any}'><span class="jlbinding">SindbadML.vegKAoneHotbatch</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegKAoneHotbatch(pft_data, ka_labels)
```


**Arguments**
- `pft_data`: Vector array
  
- `ka_labels`: KeyedArray labels, i.e. site names
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegOneHot-Tuple{Any}' href='#SindbadML.vegOneHot-Tuple{Any}'><span class="jlbinding">SindbadML.vegOneHot</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegOneHot(v_class; vegetation_labels)
```


**Arguments**
- `v_class`: get it by doing `toClass(x; vegetation_rules)`.
  
- `vegetation_labels`: see them by typing `vegetation_labels`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.vegOneHotbatch-Tuple{Any}' href='#SindbadML.vegOneHotbatch-Tuple{Any}'><span class="jlbinding">SindbadML.vegOneHotbatch</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
vegOneHotbatch(veg_classes; vegetation_labels)
```


**Arguments**
- veg_classes: get these from `toClass.([x1, x2,...])`
  
- vegetation_labels: see them by typing `vegetation_labels`
  

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadML.batchShuffler-Tuple{Any, Any, Any}' href='#SindbadML.batchShuffler-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadML.batchShuffler</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
batchShuffler(x_forcings, ids_forcings, batch_size; bs_seed=1456)
```


Shuffles the batches of forcings and their corresponding indices.

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
  

</details>

