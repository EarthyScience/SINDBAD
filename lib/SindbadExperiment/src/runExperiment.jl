export prepExperiment
export runExperiment
export runExperimentCost
export runExperimentForward
export runExperimentOpti

"""
    prepExperiment(sindbad_experiment::String; replace_info = nothing)

prepares info, forcing and output NT for the experiment
"""
function prepExperiment(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    @info "prepExperiment: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    @info "\n----------------------------------------------\n"
    @info "prepExperiment: get forcing namedtuple..."
    forcing = getForcing(info)

    @info "\n----------------------------------------------\n"

    return info, forcing
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
            info.tem.models.forward,
            forcing,
            info.tem)
    else
        run_output = runTEM!(forcing, info)
    end
    return run_output
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
    setLogLevel(:warn)
    observations = getObservation(info, forcing.helpers)
    additionaldims = setdiff(keys(forcing.helpers.sizes), info.forcing.data_dimension.time)
    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = optimizeTEMYax(forcing,
            info.tem,
            info.optim,
            observations,
            ;
            max_cache=info.experiment.exe_rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
        optim_params = optimizeTEM(forcing, obs_array, info, info.tem.helpers.run.land_output_type)
        optim_file_prefix = joinpath(info.output.optim, info.experiment.basics.name * "_" * info.experiment.basics.domain)
        CSV.write(optim_file_prefix * "_model_parameters_to_optimize.csv", optim_params)
        run_output = optim_params.optim
    end
    setLogLevel()
    return run_output
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
    @time output_array = runTEM!(forcing, info)
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------\n")
    loss_vector = getLossVector(obs_array, output_array, prepCostOptions(obs_array, info.optim.cost_options))
    println(Pair.(info.optim.observational_constraints,  loss_vector))
    return loss_vector
end


"""
    runExperimentForward(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentForward(sindbad_experiment::String; replace_info=nothing)
    setLogLevel()
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, info.tem.helpers.run.run_forward)
    @info "runExperimentForward: preparing output info for writing output..."
    output = prepTEMOut(info, forcing.helpers);
    saveOutCubes(info, run_output, output.dims, output.variables)
    return run_output
end


"""
    runExperimentOpti(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, info.tem.helpers.run.run_optimization)
    return run_output
end


"""
    runExperimentCost(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentCost(sindbad_experiment::String; replace_info=nothing)
    info, forcing = prepExperiment(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, info.tem.helpers.run.calc_cost)
    return run_output
end
