
# Machine Learning Methods in SindbadML {#Machine-Learning-Methods-in-SindbadML}

This page provides an overview of machine learning methods available within SindbadML. It includes details on various components such as activation functions, gradient methods, ML models, optimizers, and training methods, and how to extend them for experiment related to hybrid ML-physical modeling.

# Extending SindbadML: How to Add New Components {#Extending-SindbadML:-How-to-Add-New-Components}

This guide shows how to add new **activation functions**, **gradient methods**, **ML models**, **optimizers**, and **training methods** by following the conventions in the `src/Types/MLTypes.jl` and related files.


---


## 1. Adding a New Activation Function {#1.-Adding-a-New-Activation-Function}

### Step 1: Define the Activation Type {#Step-1:-Define-the-Activation-Type}

In `src/Types/MLTypes.jl`, add a new struct subtype of `ActivationType` and export it:

```julia
export MyActivation

struct MyActivation <: ActivationType end
purpose(::Type{MyActivation}) = "Describe your activation function here"
```


### Step 2: Implement the Activation Function {#Step-2:-Implement-the-Activation-Function}

In `lib/SindbadML/src/activationFunctions.jl`, extend `activationFunction`:

```julia
function activationFunction(model_options, ::MyActivation)
    # Example: Swish activation
    swish(x) = x * Flux.sigmoid(x)
    return swish
end
```



---


## 2. Adding a New Gradient Method {#2.-Adding-a-New-Gradient-Method}

### Step 1: Define the Gradient Type {#Step-1:-Define-the-Gradient-Type}

In `src/Types/MLTypes.jl`, add and export your new gradient type:

```julia
export MyGradMethod

struct MyGradMethod <: MLGradType end
purpose(::Type{MyGradMethod}) = "Describe your gradient method"
```


### Step 2: Implement the Gradient Logic {#Step-2:-Implement-the-Gradient-Logic}

In `lib/SindbadML/src/mlGradient.jl`, extend `gradientSite` and/or `gradientBatch!`:

```julia
function gradientSite(::MyGradMethod, x_vals::AbstractArray, gradient_options::NamedTuple, loss_f::F) where {F}
    # Implement your gradient calculation here
    return my_gradient(x_vals, loss_f)
end
```



---


## 3. Adding a New ML Model {#3.-Adding-a-New-ML-Model}

### Step 1: Define the Model Type {#Step-1:-Define-the-Model-Type}

In `src/Types/MLTypes.jl`, add and export your new model type:

```julia
export MyMLModel

struct MyMLModel <: MLModelType end
purpose(::Type{MyMLModel}) = "Describe your ML model"
```


### Step 2: Implement the Model Constructor {#Step-2:-Implement-the-Model-Constructor}

In `lib/SindbadML/src/mlModels.jl`, extend `mlModel`:

```julia
function mlModel(info, n_features, ::MyMLModel)
    # Build and return your model
    return MyModelConstructor(n_features, ...)
end
```



---


## 4. Adding a New Optimizer {#4.-Adding-a-New-Optimizer}

### Step 1: Define the Optimizer Type {#Step-1:-Define-the-Optimizer-Type}

In `src/Types/MLTypes.jl`, add and export your optimizer type:

```julia
export MyOptimizer

struct MyOptimizer <: MLOptimizerType end
purpose(::Type{MyOptimizer}) = "Describe your optimizer"
```


### Step 2: Implement the Optimizer Constructor {#Step-2:-Implement-the-Optimizer-Constructor}

In `lib/SindbadML/src/mlOptimizers.jl`, extend `mlOptimizer`:

```julia
function mlOptimizer(optimizer_options, ::MyOptimizer)
    # Return an optimizer object
    return MyOptimizerConstructor(optimizer_options...)
end
```



---


## 5. Adding a New Training Method {#5.-Adding-a-New-Training-Method}

### Step 1: Define the Training Type {#Step-1:-Define-the-Training-Type}

In `src/Types/MLTypes.jl`, add and export your training type:

```julia
export MyTrainingMethod

struct MyTrainingMethod <: MLTrainingType end
purpose(::Type{MyTrainingMethod}) = "Describe your training method"
```


### Step 2: Implement the Training Function {#Step-2:-Implement-the-Training-Function}

In `lib/SindbadML/src/mlTrain.jl`, extend `trainML`:

```julia
function trainML(hybrid_helpers, ::MyTrainingMethod)
    # Implement your training loop here
end
```



---


## 6. Register and Use Your New Types {#6.-Register-and-Use-Your-New-Types}
- **Export** your new types in `MLTypes.jl`.
  
- Reference your new types in experiment or parameter JSON files (e.g., `"activation_out": "my_activation"`).
  
- Make sure your new types are imported where needed.
  


---


## Summary Table {#Summary-Table}

|       Component |     Abstract Type |                        File(s) to Edit |               Function to Extend |
| ---------------:| -----------------:| --------------------------------------:| --------------------------------:|
|      Activation |  `ActivationType` | `MLTypes.jl`, `activationFunctions.jl` |             `activationFunction` |
| Gradient Method |      `MLGradType` |          `MLTypes.jl`, `mlGradient.jl` | `gradientSite`, `gradientBatch!` |
|        ML Model |     `MLModelType` |            `MLTypes.jl`, `mlModels.jl` |                        `mlModel` |
|       Optimizer | `MLOptimizerType` |        `MLTypes.jl`, `mlOptimizers.jl` |                    `mlOptimizer` |
| Training Method |  `MLTrainingType` |             `MLTypes.jl`, `mlTrain.jl` |                        `trainML` |



---


**Tip:** Always add a `purpose(::Type{YourType})` method for documentation and introspection.   **Tip:** Export your new types for use in other modules.

For more examples, see the existing code in the referenced files.
