export globalSensitivity



"""
    globalSensitivity(cost_function, method_options, p_bounds, ::GSAMethod; batch=true)

Performs global sensitivity analysis using the specified method.

# Arguments:
- `cost_function`: A function that computes the cost or output of the model based on input parameters.
- `method_options`: A set of options specific to the chosen sensitivity analysis method.
- `p_bounds`: A vector or matrix specifying the bounds of the parameters for sensitivity analysis.
- `::GSAMethod`: The sensitivity analysis method to use.
- `batch`: A boolean flag indicating whether to perform batch processing (default: `true`).

# Returns:
- A `results` object containing the sensitivity indices and other relevant outputs for the specified method.

# algorithm:
    
    $(methodsOf(GSAMethod))

---

# Extended help

## Notes:
- The function internally calls the `gsa` function from the GlobalSensitivity.jl package with the specified method and options.
- The `cost_function` should be defined to compute the model output based on the input parameters.
- The `method_options` argument allows fine-tuning of the sensitivity analysis process for each method.

"""
function globalSensitivity end

function globalSensitivity(cost_function, method_options, p_bounds, ::GSAMorris; batch=true)
    results = gsa(cost_function, Morris(; method_options...), p_bounds, batch=batch)
    return results
end


function globalSensitivity(cost_function, method_options, p_bounds, ::GSASobol; batch=true)
    sampler = getproperty(SindbadOptimization.GlobalSensitivity, Symbol(method_options.sampler))(; method_options.sampler_options..., method_options.method_options... )
    results = gsa(cost_function, sampler, p_bounds; method_options..., batch=batch)
    return results
end


function globalSensitivity(cost_function, method_options, p_bounds, ::GSASobolDM; batch=true)
    sampler = getproperty(SindbadOptimization.GlobalSensitivity, Symbol(method_options.sampler))(; method_options.sampler_options...)
    samples = method_options.samples
    lb = first.(p_bounds)
    ub = last.(p_bounds)
    A, B = QuasiMonteCarlo.generate_design_matrices(samples, lb, ub, sampler)
    results = gsa(cost_function, Sobol(; method_options.method_options...), A, B; method_options..., batch=batch)
    return results
end
