export globalSensitivity



"""
    globalSensitivity(cost_function, method_options, p_bounds, ::SindbadGlobalSensitivityMethod; batch=false)

Performs global sensitivity analysis using the specified method.

# Arguments:
- `cost_function`: A function that computes the cost or output of the model based on input parameters.
- `method_options`: A set of options specific to the chosen sensitivity analysis method.
- `p_bounds`: A vector or matrix specifying the bounds of the parameters for sensitivity analysis.
- `::SindbadGlobalSensitivityMethod`: The sensitivity analysis method to use. Supported methods include:
  - `GlobalSensitivityMorris`: Uses the Morris method for sensitivity analysis.
  - `GlobalSensitivitySobol`: Uses the Sobol method for sensitivity analysis.
  - `GlobalSensitivitySobolDM`: Uses the Sobol method with Design Matrices.
- `batch`: A boolean flag indicating whether to perform batch processing (default: `false`).

# Returns:
- A `results` object containing the sensitivity indices and other relevant outputs for the specified method.

# Notes:
- The function internally calls the `gsa` function from the GlobalSensitivity.jl package with the specified method and options.
- The `cost_function` should be defined to compute the model output based on the input parameters.
- The `method_options` argument allows fine-tuning of the sensitivity analysis process for each method.
"""
globalSensitivity

function globalSensitivity(cost_function, method_options, p_bounds, ::GlobalSensitivityMorris; batch=false)
    results = gsa(cost_function, Morris(; method_options...), p_bounds, batch=batch)
    return results
end


function globalSensitivity(cost_function, method_options, p_bounds, ::GlobalSensitivitySobol; batch=false)
    results = gsa(cost_function, Sobol(; method_options...), p_bounds, batch=batch)
    return results
end


function globalSensitivity(cost_function, method_options, p_bounds, ::GlobalSensitivitySobolDM; batch=false)
    results = gsa(cost_function, Sobol(; method_options...), p_bounds, batch=batch)
    return results
end
