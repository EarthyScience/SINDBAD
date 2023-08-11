export runExperimentForward
export runExperimentOpti


"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, output, Val{:forward})

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:forward})
    print("-------------------Forward Run Mode---------------------------\n")

    additionaldims = setdiff(keys(forcing.helpers.sizes), [:time])
    if isempty(additionaldims)
        run_output = runTEMYAX(forcing,
            output,
            info.tem,
            info.tem.models.forward;
            max_cache=info.experiment.exe_rules.yax_max_cache)
    else
        run_output = runTEM!(forcing, info)
    end
    return run_output
end


"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, output, Val{:opti})

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:opti})
    println("-------------------Optimization Mode---------------------------\n")
    observations = getObservation(info, forcing.helpers)
    additionaldims = setdiff(keys(forcing.helpers.sizes), [:time])

    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = optimizeTEMYax(forcing,
            output,
            info.tem,
            info.optim,
            observations,
            ;
            max_cache=info.experiment.exe_rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        obs_array = observations.data
        # obs_array = observations.data
        setLogLevel(:warn)
        optim_params = optimizeTEM(forcing, obs_array, info, Val(Symbol(info.optimization.land_output_type)))
        optim_file_prefix = joinpath(info.output.optim, info.experiment.basics.name * "_" * info.experiment.basics.domain)
        CSV.write(optim_file_prefix * "_model_parameters_to_optimize.csv", optim_params)
        run_output = optim_params.optim
    end
    return run_output
end

"""
    runExperiment(info::NamedTuple, forcing::NamedTuple, Val{:cost})

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `nothing`: DESCRIPTION
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, ::Val{:cost})
    observations = getObservation(info, forcing.helpers)
    obs_array = getArray(observations)

    println("-------------------Cost Calculation Mode---------------------------\n")
    @info "runExperiment: do forward run..."
    println("----------------------------------------------\n")
    @time output_array = runTEM!(forcing, info)
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------\n")
    # @time run_output = output.data
    loss_vector = getLossVector(obs_array, output_array, info.optim.cost_options)
    @info loss_vector
    return loss_vector
end


"""
    runExperimentForward(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentForward(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, output, Val(:forward))
    saveOutCubes(info, run_output, output)
    return run_output
end


"""
    runExperimentOpti(sindbad_experiment::String; replace_info = nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = nothing
    if getBool(info.experiment.flags.run_optimization)
        run_output = runExperiment(info, forcing, output, Val(:opti))
    end
    if getBool(info.experiment.flags.calc_cost) && !getBool(info.experiment.flags.run_optimization)
        run_output = runExperiment(info, forcing, Val(:cost))
    end
    return run_output
end

