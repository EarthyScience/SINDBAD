export optimizer


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Evolutionary_CMAES}) 
Optimize model parameters using CMAES method of Evolutionary.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Evolutionary_CMAES})
    optim_results = Evolutionary.optimize(cost_function, Evolutionary.BoxConstraints(lower_bounds, upper_bounds), default_values, Evolutionary.CMAES(), Evolutionary.Options(parallelization=:serial, iterations=100))
    optim_para = Evolutionary.minimizer(optim_results)
    return optim_para
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optim_LBFGS})
Optimize model parameters using LBFGS method of Optim.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optim_LBFGS})
    results = optimize(cost_function, default_values, LBFGS(), Optim.Options(show_trace=algo_options.show_trace, iterations=algo_options.iterations); autodiff=Symbol(algo_options.autodiff))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "Optim_LBFGS did not converge. Returning default as optimized parameters"
        defaults
    end
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:CMAEvolutionStrategy_CMAES})
Optimize model parameters using CMAES method of CMAEvolutionStrategy.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:CMAEvolutionStrategy_CMAES})
    results = minimize(cost_function, default_values, 1; lower=lower_bounds, upper=upper_bounds, multi_threading=algo_options.multi_threading, maxfevals=algo_options.maxfevals)
    optim_para = xbest(results)
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_Fminbox_GradientDescent}) 
Optimize model parameters using Fminbox_GradientDescent method of Optimization.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_Fminbox_GradientDescent_FD})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_fd = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_fd, default_values, lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, Fminbox(GradientDescent()))
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_NelderMead}) 
Optimize model parameters using NelderMead method of Optimization.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_NelderMead})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values)
    optim_para = solve(optim_prob, NelderMead())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_MultistartOptimization}) 
Optimize model parameters using MultistartOptimization method of Optimization.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_MultistartOptimization})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values, lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, MultistartOptimization.TikTak(100), NLopt.LD_LBFGS())
    return optim_para
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_BBO_adaptive}) 
Optimize model parameters using Black Box Optimization method of Optimization.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_BBO_adaptive})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values, lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, BBO_adaptive_de_rand_1_bin_radiuslimited())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_GCMAES}) 
Optimize model parameters using GCMAES method of Optimization.jl package
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_GCMAES})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost)
    optim_prob = OptimizationProblem(optim_cost_f, default_values, lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_GCMAES_FD}) 
Optimize model parameters using GCMAES method of Optimization.jl package with automatic forward difference
"""
function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::Val{:Optimization_GCMAES_FD})
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_f, default_values, lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end