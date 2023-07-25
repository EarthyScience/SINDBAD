export runExperimentOpti

"""
    runExperimentOpti(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:opti})
    @info "-------------------Optimization Mode---------------------------"
    observations = getObservation(info)
    additionaldims = setdiff(keys(info.tem.forcing.sizes), [:time])

    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = mapOptimizeModel(forcing,
            output,
            info.tem,
            info.optim,
            observations,
            ;
            spinup_forcing=nothing,
            max_cache=info.model_run.rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        forc_array = getKeyedArrayWithNames(forcing)
        obs_array = getKeyedArray(observations)
        optim_params = optimizeModelArray(forc_array, output, obs_array, info.tem, info.optim)
        Sindbad.CSV.write(joinpath(info.output.optim, "optimized_parameters.csv"), optim_params)
        run_output = optim_params.optim
    end
    return run_output
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:cost})
    observations = getObservation(info)
    forc_array = getKeyedArrayWithNames(forcing)
    obs_array = getKeyedArray(observations)

    @info "-------------------Cost Calculation Mode---------------------------"
    @info "runExperiment: do forward run..."
    println("----------------------------------------------")
    runEcosystem!(output, forc_array, info.tem)
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------")
    run_output = getLossVectorArray(obs_array, output.data, info.optim)
    return run_output
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)

uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = nothing
    if info.tem.helpers.run.run_optimization
        run_output = runExperiment(info, forcing, output, Val(:opti))
    end
    if info.tem.helpers.run.run_forward_and_cost && !info.tem.helpers.run.run_optimization
        run_output = runExperiment(info, forcing, output, Val(:cost))
    end
    return run_output
end
