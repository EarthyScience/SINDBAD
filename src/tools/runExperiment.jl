export runExperiment
export getExperimentInfo


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
    @info "runExperiment: load configurations..."
    info = getConfiguration(sindbad_experiment; replace_info=replace_info);

    @info "runExperiment: setup experiment..."
    info = setupExperiment(info);
    return info
end

"""
    runExperiment(sindbad_experiment::String; replace_info=nothing)
uses the configuration read from the json files, and consolidates and sets info fields needed for model simulation.
"""
function runExperiment(sindbad_experiment::String; replace_info=nothing)
    println("----------------------------------------------")
    @info "runExperiment: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)

    if info.tem.helpers.run.saveInfo
        @info "runExperiment: saving info..."
        @save joinpath(info.tem.helpers.output.settings, "info.jld2") info
    end

    if info.tem.helpers.run.catchErrors
        @info "runExperiment: setting error catcher..."
        Sindbad.eval(:(error_catcher = []))    
    end

    println("----------------------------------------------")
    @info "runExperiment: get forcing data..."
    forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
    # spinup_forcing = getSpinupForcing(forcing, info.tem);
    println("----------------------------------------------")
    
    @info "runExperiment: setup output..."
    println("----------------------------------------------")
    output = setupOutput(info);

    run_output=nothing
    observations=nothing
    if info.tem.helpers.run.runForward
        @info "runExperiment: do forward run..."
        println("----------------------------------------------")
        run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
        # save the output cubes
        # todo move this to the end of the function when the optimization takes care of one forward run from optimized_paramaters
        saveOutCubes(run_output, output.dims)
    end
    if info.tem.helpers.run.runOpti || info.tem.helpers.run.calcCost
        @info "runExperiment: get observations..."
        println("----------------------------------------------")
        observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
        if info.tem.helpers.run.runOpti
            @info "runExperiment: do optimization..."
            println("----------------------------------------------")
            output_params = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
            # save the parameters cube
            savecube(output_params,output.paramdims.backendargs[1], overwrite=true)
            #todo: run the model forward with optimized parameters and replace run_output with that. move the saveOutCubes call from above to end of this function
            # tblParams = getParameters(tem.models.forward, info_optim.optimized_paramaters)
            # # update the parameter table with the optimized values
            # tblParams.optim .= optim_para
            # updated_models = updateParameters(tblParams, tem.models.forward)
            # run_output = mapRunEcosystem(forcing, output, info.tem, updated_models; max_cache=info.modelRun.rules.yax_max_cache);
        
            run_output = output_params
        end
    end

    if info.tem.helpers.run.calcCost
        if info.tem.helpers.run.runForward
            @info "runExperiment: forward run has already been done to calculate cost"
        else
            @info "runExperiment: doing forward run"
            run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
        end
        #todo make the loss functions work with disk arrays
        # model_data = (; Pair.(output.variables, run_output)...)
        # obs_data = (; Pair.(observations.variables, observations.data)...)
        # getLossVector(obs_data, model_output, info.optim)
    end
    return run_output
end