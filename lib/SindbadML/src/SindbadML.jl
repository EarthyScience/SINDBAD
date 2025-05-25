"""
    SindbadML

The `SindbadML` package provides the core functionality for integrating machine learning (ML) and hybrid modeling capabilities into the SINDBAD framework. It enables the use of neural networks and other ML models alongside process-based models for parameter learning, and potentially hybrid modeling, and advanced optimization.

# Purpose
This package brings together all components required for hybrid (process-based + ML) modeling in SINDBAD, including data preparation, model construction, training routines, gradient computation, and optimizer management. It supports flexible configuration, cross-validation, and seamless integration with SINDBAD's process-based modeling workflows.

# Dependencies
- `Distributed`: Parallel and distributed computing utilities (`nworkers`, `pmap`, `workers`, `nprocs`, `CachingPool`).
- `Sindbad`, `SindbadTEM`, `SindbadSetup`: Core SINDBAD modules for process-based modeling and setup.
- `SindbadData.YAXArrays`, `SindbadData.Zarr`, `SindbadData.AxisKeys`, `SindbadData`: Data handling, array, and cube utilities.
- `SindbadMetrics`: Metrics for model performance/loss evaluation.
- `Enzyme`, `Zygote`, `ForwardDiff`, `FiniteDiff`, `FiniteDifferences`, `PolyesterForwardDiff`: Automatic and numerical differentiation libraries for gradient-based learning.
- `Flux`: Neural network layers and training utilities for ML models.
- `Optimisers`: Optimizers for training neural networks.
- `Statistics`: Statistical utilities.
- `ProgressMeter`: Progress bars for ML training and evaluation (`@showprogress`, `Progress`, `next!`, `progress_pmap`, `progress_map`).
- `PreallocationTools`: Tools for efficient memory allocation.
- `Base.Iterators`: Iterators for batching and repetition (`repeated`, `partition`).
- `Random`: Random number utilities.
- `JLD2`: For saving and loading model checkpoints and fold indices.

# Included Files
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

# Notes
- The package is modular and extensible, allowing users to add new ML models, optimizers, activation functions, and training methods.
- It is tightly integrated with the SINDBAD ecosystem, ensuring consistent data handling and reproducibility across hybrid and process-based modeling workflows.
"""
module SindbadML
    using Distributed:
        nworkers,
        pmap,
        workers,
        nprocs,
        CachingPool

    using Sindbad
    using SindbadTEM
    using SindbadSetup
    using SindbadData.YAXArrays
    using SindbadData.Zarr
    using SindbadData.AxisKeys
    using SindbadData: AllNaN
    using SindbadData: yaxCubeToKeyedArray, Cube
    using SindbadMetrics
    using Enzyme

    using Flux
    using Optimisers
    using FiniteDiff
    using FiniteDifferences
    using ForwardDiff
    using PolyesterForwardDiff
    using Zygote
    using Statistics
    import ProgressMeter: @showprogress, Progress, next!, progress_pmap, progress_map
    using PreallocationTools
    using Base.Iterators: repeated, partition
    using Random
    using JLD2

    include("utilsML.jl")
    include("diffCaches.jl")
    include("activationFunctions.jl")
    include("mlModels.jl")
    include("mlOptimizers.jl")
    include("loss.jl")
    include("prepHybrid.jl")
    include("mlGradient.jl")
    include("mlTrain.jl")
    include("neuralNetwork.jl")
    include("siteLosses.jl")
    include("oneHots.jl")
    include("loadCovariates.jl")

end
