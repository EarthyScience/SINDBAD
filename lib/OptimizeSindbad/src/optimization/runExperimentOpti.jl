export runExperimentOpti

"""
    runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, output_vars, ::Val{:opti})
    @info "-------------------Optimization Mode---------------------------"
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
    additionaldims = setdiff(keys(info.tem.helpers.run.loop),[:time])
    if isempty(additionaldims)
        @info "runExperiment: do optimization per pixel..."
        run_output = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
    else
        @info "runExperiment: do spatial optimization..."
        forc_array = getKeyedArrayFromYaxArray(forcing);
        obs_array = getKeyedArrayFromYaxArray(observations);
        optim_params = optimizeModelArray(forc_array, output.data, output_vars, obs_array, info.tem, info.optim)
        run_output =  optim_params.optim
    end    
    return run_output
end



"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, output_vars, ::Val{:cost})
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
    forc_array = getKeyedArrayFromYaxArray(forcing);
    obs_array = getKeyedArrayFromYaxArray(observations);

    @info "-------------------Cost Calculation Mode---------------------------"
    @info "runExperiment: do forward run..."
    println("----------------------------------------------")
    runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc_array, info.tem);
    #todo make the loss functions work with disk arrays
    @info "runExperiment: calculate cost..."
    println("----------------------------------------------")
    model_data = (; Pair.(output_vars, output.data)...)
    run_output = getLossVectorArray(obs_array, model_data, info.optim)
    return run_output
end


"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    if info.tem.helpers.run.runOpti
        run_output = runExperiment(info, forcing, output, output.variables, Val(:opti));
    end
    if info.tem.helpers.run.calcCost && !info.tem.helpers.run.runOpti
        run_output = runExperiment(info, forcing, output, output.variables, Val(:cost));
    end
    return run_output
end