export runTEMCore
export simulateTEM

function runTEMCore(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_time_series = runTimeLoop(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return land_time_series
end

function runTEMCore(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = runSpinup(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    land_time_series = runTimeLoop(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return land_time_series
end


function runTEMCore(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(selected_models, forcing_one_timestep, land_init, tem_helpers)

    runTimeLoop(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

function runTEMCore(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = runSpinup(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    runTimeLoop(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function runTimeLoop(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    for ts = 1:num_timesteps
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = runModelCompute(selected_models, f_ts, land, tem_helpers)
        land_time_series[ts] = land
    end
    return nothing
end

function runTimeLoop(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    runTimeLoop(
        selected_models,
        forcing,
        forcing_one_timestep,
        land,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function runTimeLoop(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    land_time_series = map(1:num_timesteps) do ts
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = runModelCompute(selected_models, f_ts, land, tem_helpers)
        land
    end
    return land_time_series
end

function runTimeLoop(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, 1, tem_helpers.vals.forc_vars)
    println("-------------")
    @show "each model"
    @time land = runModelCompute(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = runModelCompute(selected_models, f_ts, land, tem_helpers)
    println("-------------")
    return [land]
end


"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function simulateTEM(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info)
    land_time_series = runTEMCore(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function simulateTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_init::NamedTuple,
    tem_with_vals::NamedTuple)
    land_time_series = runTEMCore(selected_models, forcing, forcing_one_timestep, land_init, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end


"""
simulateTEM(selected_models, forcing, land_init, tem)
"""
function simulateTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_time_series,
    land_init::NamedTuple,
    tem_with_vals::NamedTuple)
    runTEMCore(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end