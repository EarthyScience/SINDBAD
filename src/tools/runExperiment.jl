export runExperiment
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
        @info "runExperiment: do forward run..."
        run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache);
        # save the output cubes
        # todo move this to the end of the function when the optimization takes care of one forward run from optimized_paramaters
        saveOutCubes(run_output, output.dims)
    end
    if info.tem.helpers.run.runOpti || info.tem.helpers.run.calcCost
        @info "runExperiment: get observations..."
        observations = getObservation(info, Val(:yaxarray));
        if info.tem.helpers.run.runOpti
            @info "runExperiment: do optimization..."
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
        # model_data = (; Pair.(output.variables, run_output)...)
        obs_data = (; Pair.(observations.variables, observations.data)...)
        #todo make the loss functions work with disk arrays
        getLossVector(obs_data, model_output, info.optim)
    end
    return info, run_output
end