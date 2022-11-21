export saveOutCubes
export getExperimentInfo
export prepExperimentForward
export prepExperimentOpti


"""
    saveOutCubes(data_vars::Tuple, data_dims::Vector)
saves the output varibles from the forward run
"""
function saveOutCubes(data_vars::Tuple, data_dims::Vector)
    for vn in eachindex(data_dims)
        data_var = data_vars[vn]
        data_dim = data_dims[vn]
        data_path = data_dim.backendargs[1]
        @info "saving $(data_path)" 
        savecube(data_var, data_path, overwrite=true)
    end
end


"""
    getExperimentInfo(experiment_json::String; replace_info=nothing)
A helper function just to get info after experiment has been loaded and modified
"""
function getExperimentInfo(sindbad_experiment::String; replace_info=nothing)
    @info "prepExperimentForward: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=replace_info);

    @info "prepExperimentForward: setup experiment..."
    info = setupExperiment(info);
    return info
end



"""
prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
    println("----------------------------------------------")

    @info "prepExperimentForward: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    if info.tem.helpers.run.saveInfo
        @info "prepExperimentForward: saving info..."
        @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    end

    if info.tem.helpers.run.catchErrors
        @info "prepExperimentForward: setting error catcher..."
        Sindbad.eval(:(error_catcher = []))    
    end
    println("----------------------------------------------")
    @info "prepExperimentForward: get forcing data..."
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    println("----------------------------------------------")
    
    @info "prepExperimentForward: setup output..."
    println("----------------------------------------------")
    output = setupOutput(info);
    return info, forcing, output

end



"""
prepExperimentOpti(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function prepExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    println("----------------------------------------------")

    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)

    @info "runExperiment: get observations..."
    println("----------------------------------------------")
    observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
    return info, forcing, output, observations

end