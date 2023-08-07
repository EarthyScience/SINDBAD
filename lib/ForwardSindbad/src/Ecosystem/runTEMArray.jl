export coreTEM!
export runTEM!
export TEM!

function coreTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    timeLoopTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_prec,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

function coreTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land_init,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = precomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        land_prec,
        tem_helpers,
        tem_models,
        tem_spinup)

    timeLoopTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_spin,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function parallelizeTEM!(
    selected_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:threads})
    Threads.@threads for space_index ∈ eachindex(loc_space_inds)
        thread_id = Threads.threadid()
        TEM!(
            selected_models,
            forcing_nt_array,
            loc_forcings[thread_id],
            forcing_one_timestep,
            output_array,
            loc_outputs[thread_id],
            land_init_space[space_index],
            loc_space_inds[space_index],
            tem_helpers,
            tem_models,
            tem_spinup)
    end
    return nothing
end

"""
parallelizeTEM!((output_array, selected_models, forcing, tem_helpers, tem_spinup, tem_models, loc_space_inds, loc_forcings, loc_outputs, land_init_space, forcing_one_timestep, ::Val{:qbmap})
"""
function parallelizeTEM!(
    selected_models,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:qbmap})
    space_index = 1
    qbmap(loc_space_inds) do loc_space_ind
        thread_id = Threads.threadid()
        TEM!(
            selected_models,
            forcing_nt_array,
            loc_forcings[thread_id],
            forcing_one_timestep,
            output_array,
            loc_outputs[thread_id],
            land_init_space[space_index],
            loc_space_inds[space_index],
            tem_helpers,
            tem_models,
            tem_spinup)
        space_index += 1
    end
    return nothing
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function runTEM!(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, _, _, tem_with_vals = prepTEM(forcing, info)
    runTEM!(tem_with_vals.models.forward, forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, tem_with_vals)
    return output_array
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function runTEM!(
    selected_models,
    forcing_nt_array::NamedTuple,
    loc_forcings,
    forcing_one_timestep,
    output_array::AbstractArray,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals::NamedTuple)
    parallelizeTEM!(
        selected_models,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals.helpers,
        tem_with_vals.models,
        tem_with_vals.spinup,
        tem_with_vals.helpers.run.parallelization)
    return nothing
end

function TEM!(
    selected_models,
    forcing,
    loc_forcing,
    forcing_one_timestep,
    output_array,
    loc_output,
    land_init,
    loc_space_ind,
    tem_helpers,
    tem_models,
    tem_spinup)
    getLocForcing!(forcing, loc_forcing, loc_space_ind, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names)
    getLocOutput!(output_array, loc_output, loc_space_ind)
    coreTEM!(
        selected_models,
        loc_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem_helpers,
        tem_models,
        tem_spinup,
        tem_helpers.run.spinup.run_spinup)
    return nothing
end


function timeLoopTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_timesteps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    for ts ∈ 1:num_timesteps
        f_ts = getForcingForTimeStep(loc_forcing, forcing_one_timestep, ts, tem_helpers.vals.forc_vars)
        land = computeTEM(selected_models, f_ts, land, tem_helpers)
        setOutputForTimeStep!(loc_output, land, ts, tem_helpers.vals.output_vars)
    end
    return nothing
end


function timeLoopTEM!(
    selected_models,
    loc_forcing,
    forcing_one_timestep,
    loc_output,
    land,
    tem_helpers,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(loc_forcing, forcing_one_timestep, 1, tem_helpers.vals.forc_vars)
    println("-------------")
    @show "each model"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = computeTEM(selected_models, f_ts, land, tem_helpers)
    println("-------------")
    @show "set output"
    @time setOutputForTimeStep!(loc_output, land, 1, tem_helpers.vals.output_vars)
    println("-------------")
    return nothing
end
