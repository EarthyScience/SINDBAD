export prepExperiment
export runExperiment
export runExperimentCost
export runExperimentForward
export runExperimentFullOutput
export runExperimentOpti

"""
    prepExperiment(sindbad_experiment::String; replace_info = nothing)

prepares info, forcing and output NT for the experiment
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
    runExperiment(info::NamedTuple, forcing::NamedTuple, ::DoCalcCost)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `::DoCalcCost`: a type dispatch for calculating cost
"""
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
    return (; forcing, info, loss=loss_vector, observation=obs_array, output=forward_output)
end



"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::DoRunForward)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::Union{DoRunForward, DoNotRunOptimization}`: a type dispatch for forward run when it is true, or when optimization is false
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, ::Union{DoRunForward, DoNotRunOptimization})
    print("-------------------Forward Run Mode---------------------------\n")
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
    return (; forcing, info, output=run_output)
end


"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::DoRunOptimization)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `::DoRunOptimization`: a type dispatch for running optimization
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, ::DoRunOptimization)
    println("-------------------Optimization Mode---------------------------\n")
    # setLogLevel(:warn)
    observations = getObservation(info, forcing.helpers)
    additionaldims = setdiff(keys(forcing.helpers.sizes), info.settings.forcing.data_dimension.time)
    run_output = nothing
    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = optimizeTEMYax(forcing, info.tem, info.optimization, observations; max_cache=info.settings.experiment.exe_rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
        optim_params = optimizeTEM(forcing, obs_array, info, info.helpers.run.land_output_type)
        optim_file_prefix = joinpath(info.output.dirs.optimization, info.experiment.basics.name * "_" * info.experiment.basics.domain)
        CSV.write(optim_file_prefix * "_model_parameters_to_optimize.csv", optim_params)
        run_output = optim_params.optim
    end
    setLogLevel()
    return (; forcing, info, observation=obs_array, params=run_output)
end


"""
    runExperimentCost(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentCost(sindbad_experiment::String; replace_info=Dict())
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = true
    replace_info["experiment.flags.run_forward"] = true
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    cost_output = runExperiment(info, forcing, info.helpers.run.calc_cost)
    return cost_output
end


"""
    runExperimentForward(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentForward(sindbad_experiment::String; replace_info=Dict())
    setLogLevel()
    replace_info["experiment.flags.run_forward"] = true
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, info.helpers.run.run_forward)
    output_dims = getOutDims(info, forcing.helpers)
    saveOutCubes(info, values(run_output.output), output_dims, info.output.variables)
    return run_output
end



"""
    runExperimentForwardParams(params_vector::Vector, sindbad_experiment::String; replace_info=Dict())

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentForwardParams(params_vector::Vector, sindbad_experiment::String; replace_info=Dict())
    @info "runExperimentForwardParams: forward run of the model with default/settings and input/optimized parameters..."
    setLogLevel(:error)
    replace_info = deepcopy(replace_info)
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = true
    replace_info["experiment.flags.run_forward"] = true
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)

    default_models = info.models.forward;

    default_output = runTEM!(default_models, forcing, info)

    tbl_params = getParameters(default_models, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);
    optimized_models = updateModelParameters(tbl_params, default_models, params_vector)
    optimized_output = runTEM!(optimized_models, forcing, info)

    output_dims = getOutDims(info, forcing.helpers)
    saveOutCubes(info, optimized_output, output_dims, info.output.variables)
    
    forward_output = (; optimized=(; Pair.(getUniqueVarNames(info.output.variables), optimized_output)...), default=(; Pair.(getUniqueVarNames(info.output.variables), default_output)...))
    setLogLevel()
    return (; forcing, info, output=forward_output)
end


"""
    runExperimentFullOutput(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentFullOutput(sindbad_experiment::String; replace_info=Dict())
    setLogLevel()
    replace_info = deepcopy(replace_info)
    replace_info["experiment.flags.run_forward"] = true
    replace_info["experiment.flags.run_optimization"] = false
    replace_info["experiment.flags.calc_cost"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    info = @set info.helpers.run.land_output_type = LandOutArrayAll()
    run_helpers = prepTEM(info.models.forward, forcing, info)
    info = @set info.output.variables = run_helpers.output_vars
    runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    output_dims = run_helpers.output_dims
    run_output = run_helpers.output_array
    saveOutCubes(info, run_output, output_dims, run_helpers.output_vars)
    return (; forcing, info, output=(; Pair.(getUniqueVarNames(run_helpers.output_vars), run_output)...))
end


"""
    runExperimentOpti(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=Dict())
    replace_info["experiment.flags.run_optimization"] = true
    replace_info["experiment.flags.calc_cost"] = false
    replace_info["experiment.flags.run_forward"] = false
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    opti_output = runExperiment(info, forcing, info.helpers.run.run_optimization)
    fp_output = runExperimentForwardParams(opti_output.params, sindbad_experiment; replace_info=replace_info)
    cost_options = prepCostOptions(opti_output.observation, info.optimization.cost_options)
    loss_vector = metricVector(fp_output.output.optimized, opti_output.observation, cost_options)
    loss_vector_def = metricVector(fp_output.output.default, opti_output.observation, cost_options)
    loss_table = Table((; variable=cost_options.variable, metric=cost_options.cost_metric, loss_opt=loss_vector, loss_def=loss_vector_def))
    display(loss_table)
    return (; forcing, info=fp_output.info, loss=loss_table, observation=opti_output.observation, output=fp_output.output, params=opti_output.params)
end

