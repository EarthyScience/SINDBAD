export runTEM!
export runTEMCore!
export TEM!

function parallelizeTEM!(output_array,
    selected_models,
    forcing_nt_array,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:threads})
    Threads.@threads for space_index ∈ eachindex(loc_space_inds)
        thread_id = Threads.threadid()
        runTEM!(output_array,
            selected_models,
            forcing_nt_array,
            loc_space_inds[space_index],
            loc_forcings[thread_id],
            loc_outputs[thread_id],
            land_init_space[space_index],
            f_one,
            tem_helpers,
            tem_models,
            tem_spinup)
    end
    return nothing
end

"""
parallelizeTEM!((output_array, selected_models, forcing, tem_helpers, tem_spinup, tem_models, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, ::Val{:qbmap})
"""
function parallelizeTEM!(output_array,
    selected_models,
    forcing_nt_array,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:qbmap})
    space_index = 1
    qbmap(loc_space_inds) do loc_space_ind
        runTEM!(output_array,
            selected_models,
            forcing_nt_array,
            loc_space_ind,
            loc_forcings[Threads.threadid()],
            loc_outputs[Threads.threadid()],
            land_init_space[space_index],
            f_one,
            tem_helpers,
            tem_models,
            tem_spinup)
        space_index += 1
    end
    return nothing
end

function runTEMCore!(loc_output,
    selected_models,
    loc_forcing,
    land_init,
    f_one,
    tem_helpers,
    _,
    _,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    runTimeLoop!(loc_output,
        selected_models,
        loc_forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_helpers.vals.debug_model)
    return nothing
end

function runTEMCore!(loc_output,
    selected_models,
    loc_forcing,
    land_init,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    land_spin = runSpinup(selected_models,
        loc_forcing,
        land_prec,
        f_one,
        tem_helpers,
        tem_models,
        tem_spinup)

    runTimeLoop!(loc_output,
        selected_models,
        loc_forcing,
        land_spin,
        f_one,
        tem_helpers,
        tem_helpers.run.debug_model)
    return nothing
end

function runTEM!(output_array,
    selected_models,
    forcing,
    loc_space_ind,
    loc_forcing,
    loc_output,
    land_init,
    f_one,
    tem_helpers,
    tem_models,
    tem_spinup)
    getLocForcing!(forcing, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names, loc_forcing, loc_space_ind)
    getLocOutput!(output_array, loc_space_ind, loc_output)
    runTEMCore!(loc_output,
        selected_models,
        loc_forcing,
        land_init,
        f_one,
        tem_helpers,
        tem_models,
        tem_spinup,
        tem_helpers.run.spinup.run_spinup)
    return nothing
end


function runTimeLoop!(loc_output,
    selected_models,
    loc_forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:false}) # do not debug the models
    num_time_steps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    for ts ∈ 1:num_time_steps
        f_ts = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, ts, f_one)
        land = runModelCompute(land, f_ts, selected_models, tem_helpers)
        setOutputForTimeStep!(loc_output, land, tem_helpers.vals.output_vars, ts)
    end
    return nothing
end


function runTimeLoop!(loc_output,
    selected_models,
    loc_forcing,
    land,
    f_one,
    tem_helpers,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, 1, f_one)
    println("-------------")
    @show "each model"
    @time land = runModelCompute(land, f_ts, selected_models, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = runModelCompute(land, f_ts, selected_models, tem_helpers)
    println("-------------")
    @show "set output"
    @time setOutputForTimeStep!(loc_output, land, tem_helpers.vals.output_vars, 1)
    println("-------------")
    return nothing
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function TEM!(forcing::NamedTuple, info::NamedTuple)
    forcing_nt_array, output_array, _, _, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one = prepTEM(forcing, info)
    TEM!(output_array, tem_with_vals.models.forward, forcing_nt_array, tem_with_val, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    return output_array
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function TEM!(output_array::AbstractArray,
    selected_models,
    forcing_nt_array::NamedTuple,
    tem_with_vals::NamedTuple,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    parallelizeTEM!(output_array,
        selected_models,
        forcing_nt_array,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one,
        tem_with_vals.helpers,
        tem_with_vals.models,
        tem_with_vals.spinup,
        tem_with_vals.helpers.run.parallelization)
    return nothing
end
