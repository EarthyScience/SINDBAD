"""
    SindbadMetrics

The `SindbadMetrics` package provides tools for evaluating the performance of SINDBAD models. It includes a variety of metrics for comparing model outputs with observations, calculating statistical measures, and updating model parameters based on evaluation results.


# Purpose:
This package is designed to define and compute metrics that assess the accuracy and reliability of SINDBAD models. It supports a wide range of statistical and performance metrics, enabling robust model evaluation and calibration.

It has heavy usage in `SindbadOptimization` but the package is separated to reduce to import burdens of optimization schemes. This allows for import into independent workflows for model evaluation and parameter estimation, e.g., in hybrid modeling.

# Dependencies:
- `Sindbad`: Provides the core SINDBAD models and types.
- `SindbadUtils`: Provides utility functions for handling data and NamedTuples, which are essential for metric calculations.

# Included Files:

1. **`handleDataForLoss.jl`**:
   - Implements functions for preprocessing and handling data before calculating loss functions or metrics.

2. **`getMetrics.jl`**:
   - Provides functions for retrieving and organizing metrics based on model outputs and observations.

3. **`metrics.jl`**:
   - Contains the core metric definitions, including statistical measures (e.g., RMSE, correlation) and custom metrics for SINDBAD experiments.


!!! note
    - The package is designed to be extensible, allowing users to define custom metrics for specific use cases.
    - Metrics are computed in a modular fashion, ensuring compatibility with SINDBAD's optimization and evaluation workflows.
    - Supports both standard statistical metrics and domain-specific metrics tailored to SINDBAD experiments.

# Examples:
1. **Calculating RMSE**:
```julia
using SindbadMetrics
rmse = metric(model_output, observations, RMSE())
```

2. **Computing correlation**:
```julia
using SindbadMetrics
correlation = metric(model_output, observations, Pcor())
```

"""
module SindbadMetrics

   using Sindbad
   using SindbadUtils

   include("handleDataForLoss.jl")
   include("getMetrics.jl")
   include("metrics.jl")

end # module SindbadMetrics
