export optimizer


"""
    mergeAlgoOptions(def_o, u_o)

merge the default and user options for optimization algorithm

# Arguments:
- `def_o`: a set of default options
- `u_o`: a NT of user defined options
"""
function mergeAlgoOptions(def_o, u_o)
    c_o = deepcopy(def_o)
    for p in keys(u_o)

        c_o = mergeAlgoOptionsSetValue(c_o, p, getproperty(u_o, p))
    end
    return c_o
end

"""
    mergeAlgoOptionsSetValue(o::NamedTuple, p, v)

helper function to set the value of field

# Arguments:
- `o`: the options NT
- `p`: field name
- `v`: filed value
"""
function mergeAlgoOptionsSetValue(o::NamedTuple, p, v)
    o = @set o[p] = v
    return o
end

"""
    mergeAlgoOptionsSetValue(o, p, v)

helper function to set the value of field

# Arguments:
- `o`: the options Mutable Struct for BayesOpt
- `p`: field name
- `v`: filed value
"""
function mergeAlgoOptionsSetValue(o, p, v)
    Base.setproperty!(o, p, v);
    return o
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::BayesOptKMaternARD5)

Optimize model parameters using kMaternARD5 method of BayesOpt.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `BayesOptKMaternARD5`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::BayesOptKMaternARD5)
    config = ConfigParameters()   # calls initialize_parameters_to_default of the C API
    config = mergeAlgoOptions(config, algo_options)
    set_kernel!(config, "kMaternARD5")  # calls set_kernel of the C API
    config.sc_type = SC_MAP
    _, optimum = bayes_optimization(cost_function, lower_bounds, upper_bounds, config)
    @show optimum
    return optimum
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::CMAEvolutionStrategyCMAES)

Optimize model parameters using CMAES method of CMAEvolutionStrategy.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `CMAEvolutionStrategyCMAES`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::CMAEvolutionStrategyCMAES)
    results = minimize(cost_function,
        default_values,
        1;
        lower=lower_bounds,
        upper=upper_bounds,
        algo_options...)
    optim_para = xbest(results)
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::EvolutionaryCMAES)

Optimize model parameters using CMAES method of Evolutionary.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `EvolutionaryCMAES`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::EvolutionaryCMAES)
    optim_results = Evolutionary.optimize(cost_function,
        Evolutionary.BoxConstraints(lower_bounds, upper_bounds),
        default_values,
        Evolutionary.CMAES(),
        Evolutionary.Options(; algo_options...))
    optim_para = Evolutionary.minimizer(optim_results)
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimLBFGS)

Optimize model parameters using LBFGS method of Optim.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimLBFGS`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimLBFGS)
    results = optimize(cost_function,
        default_values,
        LBFGS(),
        # Optim.Options(; show_trace=algo_options.show_trace,
        #     iterations=algo_options.iterations))
        Optim.Options(; algo_options...))
    # ;
    # autodiff=Symbol(algo_options.autodiff))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "OptimLBFGS did not converge. Returning default as optimized parameters"
        default
    end
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimBFGS)

Optimize model parameters using BFGS method of Optim.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimBFGS`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimBFGS)
    results = optimize(cost_function, default_values, BFGS(; initial_stepnorm=0.001))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "OptimBFGS did not converge. Returning default as optimized parameters"
        default
    end
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBBOadaptive)

Optimize model parameters using Black Box Optimization method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationBBOxnes`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationBBOxnes)
    default_options = (; maxiters = 100)
    opt_options = mergeAlgoOptions(default_options, algo_options)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, BBO_xnes(); opt_options...)
    return optim_para
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBBOadaptive)

Optimize model parameters using Black Box Optimization method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationBBOadaptive`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationBBOadaptive)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, BBO_adaptive_de_rand_1_bin_radiuslimited())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBFGS)

Optimize model parameters using BFGS method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationBFGS`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationBFGS)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values)
    optim_para = solve(optim_prob, BFGS(; initial_stepnorm=0.001))
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationFminboxGradientDescentFD)

Optimize model parameters using Fminbox_GradientDescent method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationFminboxGradientDescentFD`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationFminboxGradientDescentFD)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_fd = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_fd, default_values; lb=lower_bounds,
        ub=upper_bounds)
    optim_para = solve(optim_prob, Fminbox(GradientDescent()))
    return optim_para
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationFminboxGradientDescent)

Optimize model parameters using Fminbox_GradientDescent method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationFminboxGradientDescent`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationFminboxGradientDescent)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_fd = OptimizationFunction(optim_cost)
    optim_prob = OptimizationProblem(optim_cost_fd, default_values; lb=lower_bounds,
        ub=upper_bounds)
    optim_para = solve(optim_prob)
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationGCMAESDef)

Optimize model parameters using GCMAES method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationGCMAESDef`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationGCMAESDef)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost)
    optim_prob = OptimizationProblem(optim_cost_f, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationGCMAESFD)

Optimize model parameters using GCMAES method of Optimization.jl package with automatic forward difference

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationGCMAESFD`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationGCMAESFD)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_f, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationMultistartOptimization)

Optimize model parameters using MultistartOptimization method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationMultistartOptimization`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationMultistartOptimization)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, MultistartOptimization.TikTak(100), NLopt.LD_LBFGS())
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationNelderMead)

Optimize model parameters using NelderMead method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `OptimizationNelderMead`: optimization package and algorithm
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationNelderMead)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values)
    optim_para = solve(optim_prob, NelderMead(), algo_options...)
    return optim_para
end


"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationQuadDirect)

Optimize model parameters using NelderMead method of Optimization.jl package

# Arguments:
- `cost_function`: a function handle that takes a parameter vector as input and calcutes a loss[vector]
- `default_values`: a vector of default parameter values
- `lower_bounds`: a vector of lower bounds of parameters
- `upper_bounds`: a vector of upper bounds of parameters
- `algo_options`: a set of options specific for a given optimization algorithm
- `::OptimizationQuadDirect`: QuadDIRECT through Optimization
"""
function optimizer(cost_function,
    default_values,
    lower_bounds,
    upper_bounds,
    algo_options,
    ::OptimizationQuadDirect)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, QuadDirect(), splits = ([-0.9, 0, 0.9], [-0.8, 0, 0.8]), algo_options...)
    return optim_para
end
