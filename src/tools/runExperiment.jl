export runExperiment

"""
    runExperiment(info)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(expFile::String)
    @info "runExperiment: load configurations..."
    info = getConfiguration(expFile);

    @info "runExperiment: setup experiment..."
    info = setupExperiment(info);

    @info "runExperiment: get forcing data..."
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    
    @info "runExperiment: setup output..."
    output = setupOutput(info);

    model_output=nothing
    observations=nothing
    if info.tem.helpers.run.runForward
        @info "runExperiment: doing forward run"
        run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
    end
    if info.tem.helpers.run.runOpti || info.tem.helpers.run.calcCost
        @info "runExperiment: getting observation"
        observations = getObservation(info, Val(:yaxarray));
        if info.tem.helpers.run.runOpti
            @info "runExperiment: doing optimization"
            model_output = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
        end
    end

    if info.tem.helpers.run.calcCost
        if info.tem.helpers.run.runForward
            @info "runExperiment: forward run has already been done to calculate cost"
        else
            @info "runExperiment: doing forward run"
            model_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
        end
        # model_data = (; Pair.(output.variables, run_output)...)
        obs_data = (; Pair.(observations.variables, observations.data)...)
        getLossVector(obs_data, model_output, info.optim)
    end
    return run_output
end