export runTEMCore
export TEM

function runTEMCore(
    selected_models,
    forcing,
    land_init,
    f_one,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    land_time_series = runTimeLoop(
        selected_models,
        forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return land_time_series
end

function runTEMCore(
    selected_models,
    forcing,
    land_init,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    land_spin = runSpinup(
        selected_models,
        forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_models,
        tem_spinup)

    land_time_series = runTimeLoop(
        selected_models,
        forcing,
        land_spin,
        f_one,
        tem_helpers,
        tem_helpers.run.debug_model)
    return land_time_series
end


function runTEMCore(
    land_time_series,
    selected_models,
    forcing,
    land_init,
    f_one,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    runTimeLoop(
        land_time_series,
        selected_models,
        forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

function runTEMCore(
    land_time_series,
    selected_models,
    forcing,
    land_init,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    land_spin = runSpinup(
        selected_models,
        forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_models,
        tem_spinup)

    runTimeLoop(
        land_time_series,
        selected_models,
        forcing,
        land_spin,
        f_one,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function runTimeLoop(
    land_time_series,
    selected_models,
    forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_time_steps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    for ts = 1:num_time_steps
        f_ts = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_one)
        land_time_series[ts] = runModelCompute(land, f_ts, selected_models, tem_helpers)
    end
    return nothing
end

function runTimeLoop(_,
    selected_models,
    forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:true}) # debug the models
    runTimeLoop(
        selected_models,
        forcing,
        land,
        f_one,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function runTimeLoop(
    selected_models,
    forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_time_steps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    land_time_series = map(1:num_time_steps) do ts
        f_ts = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_one)
        land = runModelCompute(land, f_ts, selected_models, tem_helpers)
        land
    end
    return land_time_series
end

function runTimeLoop(
    selected_models,
    forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(forcing, tem_helpers.vals.forc_vars, 1, f_one)
    println("-------------")
    @show "each model"
    @time land = runModelCompute(land, f_ts, selected_models, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = runModelCompute(land, f_ts, selected_models, tem_helpers)
    println("-------------")
    return nothing
end


"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function TEM(forcing::NamedTuple, info::NamedTuple)
    _, _, _, _, _, loc_forcings, _, land_init_space, tem_with_vals, f_one = prepTEM(forcing, info)
    land_time_series = runTEMCore(info.tem.models.forward, loc_forcings[1], land_init_space[1], f_one, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function TEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    f_one,
    tem_with_vals::NamedTuple)
    land_time_series = runTEMCore(selected_models, forcing, land_init, f_one, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end


"""
TEM(selected_models, forcing, land_init, tem)
"""
function TEM(
    land_time_series,
    selected_models::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    f_one,
    tem_with_vals::NamedTuple)
    runTEMCore(land_time_series, selected_models, forcing, land_init, f_one, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.run_spinup)
    return landWrapper(land_time_series)
end