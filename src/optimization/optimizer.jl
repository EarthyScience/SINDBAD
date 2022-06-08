export optimizer

"""
    optimizer(costFunc, defaults, lo, hi, algo_options, ::Val{:Optim_LBFGS})
Optimize model parameters using LBFGS method of Optim.jl package
"""
function optimizer(costFunc,  default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optim_LBFGS})
    results = optimize(costFunc, default_values, LBFGS(),Optim.Options(show_trace=algo_options.show_trace, iterations = algo_options.iterations); autodiff=Symbol(algo_options.autodiff))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "Optim_LBFGS did not converge. Returning default as optimized parameters"
        defaults
    end
    return optim_para
end


"""
optimizer(costFunc, defaults, lo, hi, algo_options, ::Val{:CMAEvolutionStrategy_CMAES})
Optimize model parameters using CMAES method of Optim.jl package
"""
function optimizer(costFunc,  default_values, lower_bounds, upper_bounds, algo_options, ::Val{:CMAEvolutionStrategy_CMAES})
    results = minimize(costFunc, default_values, 1; lower=lower_bounds, upper=upper_bounds, multi_threading=algo_options.multi_threading, maxfevals=algo_options.maxfevals)
    optim_para = xbest(results)
    return optim_para
end