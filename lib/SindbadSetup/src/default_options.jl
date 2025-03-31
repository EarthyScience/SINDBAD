export sindbad_default_options

"""
    sindbad_default_options(::MethodType)

Retrieves the default configuration options for a given optimization or sensitivity analysis method in SINDBAD.

# Arguments:
- `::MethodType`: The method type for which the default options are requested. Supported types include:
    - `SindbadOptimizationMethod`: General optimization methods.
    - `SindbadGlobalSensitivityMethod`: General global sensitivity analysis methods.
    - `GlobalSensitivityMorris`: Morris method for global sensitivity analysis.
    - `GlobalSensitivitySobol`: Sobol method for global sensitivity analysis.
    - `GlobalSensitivitySobolDM`: Sobol method with derivative-based measures.

# Returns:
- A `NamedTuple` containing the default options for the specified method.

# Notes:
- Each method type has its own set of default options, such as the number of trajectories, samples, or design matrix length.
- For `GlobalSensitivitySobolDM`, the defaults are inherited from `GlobalSensitivitySobol`.
"""
sindbad_default_options

sindbad_default_options(::SindbadOptimizationMethod) = (;)

sindbad_default_options(::SindbadGlobalSensitivityMethod) = (;)

sindbad_default_options(::GlobalSensitivityMorris) = (; total_num_trajectory = 200, num_trajectory = 15, len_design_mat=10)

sindbad_default_options(::GlobalSensitivitySobol) = (; samples = 5, method_options=(; order=[0, 1]), sampler="Sobol", sampler_options=(;))

sindbad_default_options(::GlobalSensitivitySobolDM) = sindbad_default_options(GlobalSensitivitySobol())
