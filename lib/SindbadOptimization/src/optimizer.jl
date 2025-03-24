export optimizer
export mergeAlgoOptions

"""
Merges algorithm options by combining default options with user-provided options.

This function takes two option dictionaries and combines them, with user options
taking precedence over default options.

# Arguments
- `def_o`: Default options object (NamedTuple/Struct/Dictionary) containing baseline algorithm parameters
- `u_o`: User options object containing user-specified overrides

# Returns
- A merged object containing the combined algorithm options
"""
function mergeAlgoOptions(def_o, u_o)
    c_o = deepcopy(def_o)
    for p in keys(u_o)

        c_o = mergeAlgoOptionsSetValue(c_o, p, getproperty(u_o, p))
    end
    return c_o
end

"""
    mergeAlgoOptionsSetValue(o, p, v)

Helper function to set the value of a field in the options object.

# Arguments:
- `o`: The options object, which can be a `NamedTuple` or a mutable struct.
- `p`: The field name to be updated.
- `v`: The new value to assign to the field.

# Variants:
1. **For `NamedTuple` options**:
   - Updates the field in an immutable `NamedTuple` by creating a new `NamedTuple` with the updated value.
   - Uses the `@set` macro for immutability handling.

2. **For mutable struct options (e.g., BayesOpt)**:
   - Directly updates the field in the mutable struct using `Base.setproperty!`.

# Returns:
- The updated options object with the specified field modified.

# Notes:
- This function is used internally by `mergeAlgoOptions` to handle field updates in both mutable and immutable options objects.
- Ensures compatibility with different types of optimization algorithm configurations.

# Examples:
1. **Updating a `NamedTuple`**:
    ```julia
    options = (max_iters = 100, tol = 1e-6)
    updated_options = mergeAlgoOptionsSetValue(options, :tol, 1e-8)
    ```

2. **Updating a mutable struct**:
    ```julia
    mutable struct BayesOptConfig
        max_iters::Int
        tol::Float64
    end
    config = BayesOptConfig(100, 1e-6)
    updated_config = mergeAlgoOptionsSetValue(config, :tol, 1e-8)
    `
"""
mergeAlgoOptionsSetValue

function mergeAlgoOptionsSetValue(o::NamedTuple, p, v)
    o = @set o[p] = v
    return o
end


function mergeAlgoOptionsSetValue(o, p, v)
    Base.setproperty!(o, p, v);
    return o
end

"""
    optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, algorithm <:SindbadOptimizationMethod)

Optimize model parameters using various optimization algorithms.

# Arguments:
- `cost_function`: A function handle that takes a parameter vector as input and calculates a cost/loss (scalar or vector).
- `default_values`: A vector of default parameter values to initialize the optimization.
- `lower_bounds`: A vector of lower bounds for the parameters.
- `upper_bounds`: A vector of upper bounds for the parameters.
- `algo_options`: A set of options specific to the chosen optimization algorithm.
- `algorithm <:SindbadOptimizationMethod`: The optimization algorithm to be used. Supported algorithms include:
    - `BayesOptKMaternARD5`: Uses the kMaternARD5 method from the BayesOpt.jl package.
    - `CMAEvolutionStrategyCMAES`: Uses the CMAES method from the CMAEvolutionStrategy.jl package.
    - `EvolutionaryCMAES`: Uses the CMAES method from the Evolutionary.jl package.
    - `OptimLBFGS`: Uses the LBFGS method from the Optim.jl package.
    - `OptimBFGS`: Uses the BFGS method from the Optim.jl package.
    - `OptimizationBBOxnes`: Uses the Black Box Optimization (xNES) method from the Optimization.jl package.
    - `OptimizationBBOadaptive`: Uses the Black Box Optimization (adaptive) method from the Optimization.jl package.
    - `OptimizationBFGS`: Uses the BFGS method from the Optimization.jl package.
    - `OptimizationFminboxGradientDescent`: Uses the Fminbox Gradient Descent method from the Optimization.jl package.
    - `OptimizationFminboxGradientDescentFD`: Uses the Fminbox Gradient Descent method with forward differentiation from the Optimization.jl package.
    - `OptimizationGCMAESDef`: Uses the GCMAES method from the Optimization.jl package.
    - `OptimizationGCMAESFD`: Uses the GCMAES method with forward differentiation from the Optimization.jl package.
    - `OptimizationMultistartOptimization`: Uses the Multistart Optimization method from the Optimization.jl package.
    - `OptimizationNelderMead`: Uses the Nelder-Mead method from the Optimization.jl package.
    - `OptimizationQuadDirect`: Uses the QuadDIRECT method from the Optimization.jl package.

# Returns:
- `optim_para`: A vector of optimized parameter values.

# Extended help

# Notes:
- The function supports a wide range of optimization algorithms, each tailored for specific use cases.
- Some methods do not require bounds for optimization, while others do.
- The `cost_function` should be defined by the user to calculate the loss based on the model output and observations. It is defined in cost.jl.
- The `algo_options` argument allows fine-tuning of the optimization process for each algorithm.
- Some algorithms (e.g., `BayesOptKMaternARD5`, `OptimizationBBOxnes`) require additional configuration steps, such as setting kernels or merging default and user-defined options.

# Examples:
1. **Using CMAES from CMAEvolutionStrategy.jl**:
    ```julia
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, CMAEvolutionStrategyCMAES())
    ```

2. **Using BFGS from Optim.jl**:
    ```julia
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, OptimBFGS())
    ```

3. **Using Black Box Optimization (xNES) from Optimization.jl**:
    ```julia
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, OptimizationBBOxnes())
    ```

# Implementation Details:
- The function internally calls the appropriate optimization library and algorithm based on the `algorithm` argument.
- Each algorithm has its own implementation details, such as handling bounds, configuring options, and solving the optimization problem.
- The results are processed to extract the optimized parameter vector (`optim_para`), which is returned to the user.
"""
optimizer

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::BayesOptKMaternARD5)
    config = ConfigParameters()   # calls initialize_parameters_to_default of the C API
    config = mergeAlgoOptions(config, algo_options)
    set_kernel!(config, "kMaternARD5")  # calls set_kernel of the C API
    config.sc_type = SC_MAP
    _, optimum = bayes_optimization(cost_function, lower_bounds, upper_bounds, config)
    @show optimum
    return optimum
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::CMAEvolutionStrategyCMAES)
    results = minimize(cost_function, default_values, 1; lower=lower_bounds, upper=upper_bounds, algo_options...)
    optim_para = xbest(results)
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::EvolutionaryCMAES)
    optim_results = Evolutionary.optimize(cost_function, Evolutionary.BoxConstraints(lower_bounds, upper_bounds), default_values, Evolutionary.CMAES(), Evolutionary.Options(; algo_options...))
    optim_para = Evolutionary.minimizer(optim_results)
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimLBFGS)
    results = optimize(cost_function, default_values, LBFGS(), Optim.Options(; algo_options...))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "OptimLBFGS did not converge. Returning default as optimized parameters"
        default
    end
    return optim_para
end

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimBFGS)
    results = optimize(cost_function, default_values, BFGS(; initial_stepnorm=0.001))
    optim_para = if results.ls_success
        results.minimizer
    else
        @warn "OptimBFGS did not converge. Returning default as optimized parameters"
        default
    end
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBBOxnes)
    default_options = (; maxiters = 100)
    opt_options = mergeAlgoOptions(default_options, algo_options)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, BBO_xnes(); opt_options...)
    return optim_para
end

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBBOadaptive)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, BBO_adaptive_de_rand_1_bin_radiuslimited())
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationBFGS)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values)
    optim_para = solve(optim_prob, BFGS(; initial_stepnorm=0.001))
    return optim_para
end

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationFminboxGradientDescentFD)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_fd = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_fd, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, Fminbox(GradientDescent()))
    return optim_para
end

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationFminboxGradientDescent)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_fd = OptimizationFunction(optim_cost)
    optim_prob = OptimizationProblem(optim_cost_fd, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob)
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationGCMAESDef)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost)
    optim_prob = OptimizationProblem(optim_cost_f, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationGCMAESFD)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_cost_f = OptimizationFunction(optim_cost, Optimization.AutoForwardDiff())
    optim_prob = OptimizationProblem(optim_cost_f, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, GCMAESOpt())
    return optim_para
end

function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationMultistartOptimization)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, MultistartOptimization.TikTak(100), NLopt.LD_LBFGS())
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationNelderMead)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values)
    optim_para = solve(optim_prob, NelderMead(), algo_options...)
    return optim_para
end


function optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::OptimizationQuadDirect)
    optim_cost = (p, tmp=nothing) -> cost_function(p)
    optim_prob = OptimizationProblem(optim_cost, default_values; lb=lower_bounds, ub=upper_bounds)
    optim_para = solve(optim_prob, QuadDirect(), splits = ([-0.9, 0, 0.9], [-0.8, 0, 0.8]), algo_options...)
    return optim_para
end
