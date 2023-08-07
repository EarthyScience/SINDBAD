export runExperimentOpti

"""
    runExperimentOpti(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:opti})
    println("-------------------Optimization Mode---------------------------\n")
    observations = getObservation(info, forcing.helpers)
    additionaldims = setdiff(keys(forcing.helpers.sizes), [:time])

    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = mapOptimizeModel(forcing,
            output,
            info.tem,
            info.optim,
            observations,
            ;
            max_cache=info.model_run.rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        obs_array = getArray(observations)
        # obs_array = getKeyedArray(observations)
        optim_params = optimizeTEM(forcing, obs_array, info)
        optim_file_prefix = joinpath(info.output.optim, info.experiment.name * "_" * info.experiment.domain)
        Sindbad.CSV.write(optim_file_prefix * "_optimized_parameters.csv", optim_params)
        run_output = optim_params.optim
    end
    return run_output
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, ::Val{:cost})
    observations = getObservation(info, forcing.helpers)
    obs_array = getArray(observations)

    println("-------------------Cost Calculation Mode---------------------------\n")
    @info "runExperiment: do forward run..."
    println("----------------------------------------------\n")
    @time output_array = TEM!(forcing, info)
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------\n")
    # @time run_output = output.data
    loss_vector = getLossVector(obs_array, output_array, info.optim.cost_options)
    @info loss_vector
    return loss_vector
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = nothing
    if getBool(info.tem.helpers.run.run_optimization)
        run_output = runExperiment(info, forcing, output, Val(:opti))
    end
    if getBool(info.tem.helpers.run.run_forward_and_cost) && !getBool(info.tem.helpers.run.run_optimization)
        run_output = runExperiment(info, forcing, Val(:cost))
    end
    return run_output
end
