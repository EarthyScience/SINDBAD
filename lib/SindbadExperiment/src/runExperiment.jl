export prepExperiment
export runExperiment
export runExperimentCost
export runExperimentForward
export runExperimentFullOutput
export runExperimentOpti
export runExperimentSensitivity

"""
    prepExperiment(sindbad_experiment::String; replace_info::Dict=Dict())

Prepare experiment configuration, forcing data, and output settings.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)

# Returns
- `info::NamedTuple`: A NamedTuple containing the experiment configuration
- `forcing::NamedTuple`: A NamedTuple containing the forcing data

# Description
This function initializes an experiment by:
1. Reading and processing the experiment configuration
2. Setting up forcing data based on the configuration
3. Preparing output settings
"""
function prepExperiment(sindbad_experiment::String; replace_info=Dict())
    @info "\n----------------------------------------------\n"
    sindbadBanner()
    @info "\n----------------------------------------------\n"
    @info "\n----------------------------------------------\n"
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    @info "\n----------------------------------------------\n"
    forcing = getForcing(info)

    @info "\n----------------------------------------------\n"

    return info, forcing
end


"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, mode)

Run a SINDBAD experiment in different modes.

# Arguments
- `info::NamedTuple`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment
- `forcing::NamedTuple`: A forcing NamedTuple containing the forcing time series set for ALL locations
- `mode`: Type dispatch parameter determining the mode of experiment:
  - `DoCalcCost`: Calculate cost between model output and observations
  - `DoRunForward`: Run forward simulation without optimization
  - `DoNotRunOptimization`: Run without optimization
  - `DoRunOptimization`: Run with optimization enabled

# Returns
- For `DoCalcCost` mode:
  - `(; forcing, info, loss=loss_vector, observation=obs_array, output=forward_output)`
- For `DoRunForward` or `DoNotRunOptimization` mode:
  - `(; forcing, info, output=run_output)`
- For `DoRunOptimization` mode:
  - `(; forcing, info, observation=obs_array, params=run_output)`

# Description
This function is the main entry point for running SINDBAD experiments. It supports different modes of simulation:
- Cost calculation: Compares model output with observations
- Forward run: Executes the model without optimization
- Optimization: Runs the model with parameter optimization

The function handles different spatial configurations and can operate on both single-pixel and spatial domains.
"""
function runExperiment end

function runExperiment(info::NamedTuple, forcing::NamedTuple, ::DoCalcCost)
    setLogLevel()
    observations = getObservation(info, forcing.helpers)
    obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
    println("-------------------Cost Calculation Mode---------------------------\n")
    @info "runExperiment: do forward run..."
    println("----------------------------------------------\n")
    output_array = runTEM!(forcing, info)
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------\n")
    forward_output = (; Pair.(getUniqueVarNames(info.output.variables), output_array)...)
    cost_options = prepCostOptions(obs_array, info.optimization.cost_options)
    loss_vector = metricVector(forward_output, obs_array, cost_options)
    for _cp in Pair.(Pair.(cost_options.variable, nameof.(typeof.(cost_options.cost_metric))),  loss_vector)
        println(_cp)
    end
    setLogLevel()
    return (; forcing, info, loss=loss_vector, observation=obs_array, output=forward_output)
end


function runExperiment(info::NamedTuple, forcing::NamedTuple, ::Union{DoRunForward, DoNotRunOptimization})
    println("-------------------Forward Run Mode---------------------------\n")
    additionaldims = setdiff(keys(forcing.helpers.sizes), [:time])
    if isempty(additionaldims)
        run_output = runTEMYax(
            info.models.forward,
            forcing,
            info)
    else
        run_output = runTEM!(forcing, info)
        run_output = (; Pair.(getUniqueVarNames(info.output.variables), run_output)...)
    end
    setLogLevel()
    return (; forcing, info, output=run_output)
end


function runExperiment(info::NamedTuple, forcing::NamedTuple, ::DoRunOptimization)
    println("-------------------Optimization Mode---------------------------\n")
    observations = getObservation(info, forcing.helpers)
    additionaldims = setdiff(keys(forcing.helpers.sizes), info.experiment.data_settings.forcing.data_dimension.time)
    run_output = nothing
    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = optimizeTEMYax(forcing, info.tem, info.optimization, observations; max_cache=info.settings.experiment.exe_rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
        optim_params = optimizeTEM(forcing, obs_array, info)
        optim_file_prefix = joinpath(info.output.dirs.optimization, info.experiment.basics.name * "_" * info.experiment.basics.domain)
        CSV.write(optim_file_prefix * "_model_parameters_optimized.csv", optim_params)
        run_output = optim_params
    end
    setLogLevel()
    return (; forcing, info, observation=obs_array, parameters=run_output)
end


"""
    runExperimentCost(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)

Calculate cost for a given experiment through the `runExperiment` function in `DoCalcCost` mode.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `log_level::Symbol`: Logging level (default: :info)

# Returns
- A NamedTuple containing the experiment results including cost calculations
"""
function runExperimentCost(sindbad_experiment::String; replace_info=Dict(), log_level=:info)
    setLogLevel(log_level)
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = true
    replace_info["experiment.flags.run_forward"] = true
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    cost_output = runExperiment(info, forcing, info.helpers.run.calc_cost)
    setLogLevel()
    return cost_output
end


"""
    runExperimentForward(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)

Run forward simulation for a given experiment through the `runExperiment` function in `DoRunForward` mode.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `log_level::Symbol`: Logging level (default: :info)

# Returns
- A NamedTuple containing the experiment results including model outputs
"""
function runExperimentForward(sindbad_experiment::String; replace_info=Dict(), log_level=:info)
    setLogLevel(log_level)
    replace_info["experiment.flags.run_forward"] = true
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, info.helpers.run.run_forward)
    output_dims = getOutDims(info, forcing.helpers)
    saveOutCubes(info, values(run_output.output), output_dims, info.output.variables)
    setLogLevel()
    return run_output
end



"""
    runExperimentForwardParams(params_vector::Vector, sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)

Run forward simulation of the model with default as well as modified settings with input/optimized parameters through call of the `runTEM!` function.

# Arguments
- `params_vector::Vector`: Vector of parameters to use for the simulation
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `log_level::Symbol`: Logging level (default: :info)

# Returns
- A NamedTuple containing both default and optimized model outputs
"""
function runExperimentForwardParams(params_vector::Vector, sindbad_experiment::String; replace_info=Dict(), log_level=:info)
    setLogLevel(log_level)
    @info "runExperimentForwardParams: forward run of the model with default/settings and input/optimized parameters..."
    replace_info = deepcopy(replace_info)
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = true
    replace_info["experiment.flags.run_forward"] = true
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)

    default_models = info.models.forward;

    default_output = runTEM!(default_models, forcing, info)

    parameter_table = info.optimization.parameter_table;
    optimized_models = updateModelParameters(parameter_table, default_models, params_vector)
    optimized_output = runTEM!(optimized_models, forcing, info)

    output_dims = getOutDims(info, forcing.helpers)
    saveOutCubes(info, optimized_output, output_dims, info.output.variables)
    
    forward_output = (; optimized=(; Pair.(getUniqueVarNames(info.output.variables), optimized_output)...), default=(; Pair.(getUniqueVarNames(info.output.variables), default_output)...))
    setLogLevel()
    return (; forcing, info, output=forward_output)
end


"""
    runExperimentFullOutput(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:info)

Run forward simulation of the model through `runExperiment` function in `DoRunForward` mode but with all output variables saved.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `log_level::Symbol`: Logging level (default: :info)

# Returns
- A NamedTuple containing the complete model outputs
"""
function runExperimentFullOutput(sindbad_experiment::String; replace_info=Dict(), log_level=:info)
    setLogLevel(log_level)
    replace_info = deepcopy(replace_info)
    replace_info["experiment.flags.run_forward"] = true
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    info = @set info.helpers.run.land_output_type = PreAllocArrayAll()
    run_helpers = prepTEM(info.models.forward, forcing, info)
    info = @set info.output.variables = run_helpers.output_vars
    runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    output_dims = run_helpers.output_dims
    run_output = run_helpers.output_array
    saveOutCubes(info, run_output, output_dims, run_helpers.output_vars)
    setLogLevel()
    return (; forcing, info, output=(; Pair.(getUniqueVarNames(run_helpers.output_vars), run_output)...))
end


"""
    runExperimentOpti(sindbad_experiment::String; replace_info::Dict=Dict(), log_level::Symbol=:warn)

Run optimization experiment through `runExperiment` function in `DoRunOptimization` mode, followed by forward run with optimized parameters.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `log_level::Symbol`: Logging level (default: :warn)

# Returns
- A NamedTuple containing optimization results, model outputs, and cost metrics
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=Dict(), log_level=:warn)
    setLogLevel(log_level)
    replace_info["experiment.flags.run_optimization"] = true
    replace_info["experiment.flags.calc_cost"] = false
    replace_info["experiment.flags.run_forward"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    opti_output = runExperiment(info, forcing, info.helpers.run.run_optimization)
    setLogLevel(:info)
    fp_output = runExperimentForwardParams(opti_output.parameters.optimized, sindbad_experiment; replace_info=replace_info)
    cost_options = prepCostOptions(opti_output.observation, info.optimization.cost_options)
    loss_vector = metricVector(fp_output.output.optimized, opti_output.observation, cost_options)
    loss_vector_def = metricVector(fp_output.output.default, opti_output.observation, cost_options)
    loss_table = Table((; variable=cost_options.variable, metric=cost_options.cost_metric, loss_opt=loss_vector, loss_def=loss_vector_def))
    display(loss_table)
    return (; forcing, info=fp_output.info, loss=loss_table, observation=opti_output.observation, output=fp_output.output, parameters=opti_output.parameters)
end



"""
    runExperimentSensitivity(sindbad_experiment::String; replace_info::Dict=Dict(), batch::Bool=true, log_level::Symbol=:warn)

Run sensitivity analysis for a given experiment.

# Arguments
- `sindbad_experiment::String`: Path to the experiment configuration file
- `replace_info::Dict`: Dictionary of configuration overrides (default: empty Dict)
- `batch::Bool`: Whether to run sensitivity analysis in batch mode (default: true)
- `log_level::Symbol`: Logging level (default: :warn)

# Returns
- A NamedTuple containing sensitivity analysis results and related data
"""
function runExperimentSensitivity(sindbad_experiment::String; replace_info=Dict(), batch=true, log_level=:warn)
    println("-------------------Sensitivity Analysis Mode---------------------------\n")
    replace_info["experiment.flags.run_optimization"] = true
    replace_info["experiment.flags.calc_cost"] = false
    replace_info["experiment.flags.run_forward"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    observations = getObservation(info, forcing.helpers)

    obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

    opti_helpers = prepOpti(forcing, obs_array, info, info.optimization.run_options.cost_method; algorithm_info_field=:sensitivity_analysis);

    # parameter_table = opti_helpers.parameter_table
    p_bounds=Tuple.(Pair.(opti_helpers.lower_bounds,opti_helpers.upper_bounds))
    
    cost_function = opti_helpers.cost_function

    # d_opt = getproperty(SindbadSetup, :GSAMorris)()
    method_options =info.optimization.sensitivity_analysis.options
    setLogLevel(log_level)

    sensitivity = globalSensitivity(cost_function, method_options, p_bounds, info.optimization.sensitivity_analysis.method, batch=batch)
    sensitivity_output = (; opti_helpers..., info=info, forcing=forcing, obs_array=obs_array, observations=observations,sensitivity=sensitivity, p_bounds=p_bounds)
    setLogLevel(:info)
    sensitivity_output_file = joinpath(info.output.dirs.data, "sensitivity_analysis_$(nameof(typeof(info.optimization.sensitivity_analysis.method)))_$(length(opti_helpers.cost_vector))-cost_evals.jld2")
    @info "saving output for sensitivity: "
    @save  sensitivity_output_file sensitivity_output
    return sensitivity_output
end