export coreTEM
export runTEM

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, _, _, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_time_series = timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return land_time_series
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, tem_models, tem_spinup, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_models`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    land_time_series = timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return land_time_series
end


"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, _, _, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_time_series`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `_`: DESCRIPTION
- `_`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

"""
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_helpers, tem_models, tem_spinup, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_time_series`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `tem_models`: DESCRIPTION
- `tem_spinup`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function coreTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land_time_series,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end


"""
runEcosystem(selected_models, forcing, land_init, tem)
"""

"""
    runTEM(forcing::NamedTuple, info::NamedTuple)

DOCSTRING
"""
function runTEM(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info)
    land_time_series = coreTEM(info.tem.models.forward, loc_forcings[1], forcing_one_timestep, land_init_space[1], tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_init::NamedTuple, tem_with_vals::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_with_vals`: DESCRIPTION
"""
function runTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_init::NamedTuple,
    tem_with_vals::NamedTuple)
    land_time_series = coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end


"""
runTEM(selected_models, forcing, land_init, tem)
"""

"""
    runTEM(selected_models::Tuple, forcing::NamedTuple, forcing_one_timestep, land_time_series, land_init::NamedTuple, tem_with_vals::NamedTuple)

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_time_series`: DESCRIPTION
- `land_init`: DESCRIPTION
- `tem_with_vals`: DESCRIPTION
"""
function runTEM(
    selected_models::Tuple,
    forcing::NamedTuple,
    forcing_one_timestep,
    land_time_series,
    land_init::NamedTuple,
    tem_with_vals::NamedTuple)
    coreTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land_init, tem_with_vals.helpers, tem_with_vals.models, tem_with_vals.spinup, tem_with_vals.helpers.run.spinup.spinup_TEM)
    return landWrapper(land_time_series)
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_time_series`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
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
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land_time_series[ts] = land
    end
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_time_series, land, tem_helpers, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land_time_series`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land_time_series,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    timeLoopTEM(
        selected_models,
        forcing,
        forcing_one_timestep,
        land,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
    selected_models,
    forcing,
    forcing_one_timestep,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(forcing, tem_helpers.vals.forc_vars)
    land_time_series = map(1:num_timesteps) do ts
        f_ts = getForcingForTimeStep(forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        land
    end
    return land_time_series
end

"""
    timeLoopTEM(selected_models, forcing, forcing_one_timestep, land, tem_helpers, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `selected_models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function timeLoopTEM(
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
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers)
    println("-------------")
    return [land]
end
