export runExperimentForward

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(info::NamedTuple, forcing::NamedTuple, output, ::Val{:forward})
    @info "-------------------Forward Run Mode---------------------------"

    additionaldims = setdiff(keys(info.tem.helpers.run.loop),[:time])
    if isempty(additionaldims)
        run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
    else
        forc = getKeyedArrayFromYaxArray(forcing);
        runEcosystem!(output.data, output.land_init, info.tem.models.forward, forc, info.tem);
        run_output = output.data;
    end
    return run_output
end



"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperimentForward(sindbad_experiment::String; replace_info=nothing)
    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)
    run_output = runExperiment(info, forcing, output, Val(:forward));
    return run_output
end