export sindbadDefaultOptions

"""
    sindbadDefaultOptions(::MethodType)

Retrieves the default configuration options for a given optimization or sensitivity analysis method in SINDBAD.

# Arguments:
- `::MethodType`: The method type for which the default options are requested. Supported types include:
    - `OptimizationMethod`: General optimization methods.
    - `GSAMethod`: General global sensitivity analysis methods.
    - `GSAMorris`: Morris method for global sensitivity analysis.
    - `GSASobol`: Sobol method for global sensitivity analysis.
    - `GSASobolDM`: Sobol method with derivative-based measures.

# Returns:
- A `NamedTuple` containing the default options for the specified method.

# Notes:
- Each method type has its own set of default options, such as the number of trajectories, samples, or design matrix length.
- For `GSASobolDM`, the defaults are inherited from `GSASobol`.
"""
function sindbadDefaultOptions end
# A basic empty options for all SindbadTypes
sindbadDefaultOptions(::SindbadTypes) = (;)

sindbadDefaultOptions(::CMAEvolutionStrategyCMAES) = (; maxfevals = 50)

sindbadDefaultOptions(::GSAMorris) = (; total_num_trajectory = 200, num_trajectory = 15, len_design_mat=10)

sindbadDefaultOptions(::GSASobol) = (; samples = 5, method_options=(; order=[0, 1]), sampler="Sobol", sampler_options=(;))

sindbadDefaultOptions(::GSASobolDM) = sindbadDefaultOptions(GSASobol())
