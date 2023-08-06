export runTEM!
export runTEMCore!
export TEM!

function runTEMCore!(loc_output,
    selected_models,
    loc_forcing,
    tem_helpers,
    _,
    _,
    land_init,
    f_one,
    ::Val{:false}) # without spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    runTimeLoop!(loc_output,
        selected_models,
        loc_forcing,
        land_prec,
        tem_helpers,
        f_one,
        tem_helpers.vals.debug_model)
    return nothing
end

function runTEMCore!(loc_output,
    selected_models,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init,
    f_one,
    ::Val{:true}) # with spinup

    land_prec = runModelPrecompute(land_init, f_one, selected_models, tem_helpers)

    land_spin = runSpinup(selected_models,
        loc_forcing,
        land_prec,
        tem_helpers,
        tem_spinup,
        tem_models,
        f_one)

    runTimeLoop!(loc_output,
        selected_models,
        loc_forcing,
        land_spin,
        tem_helpers,
        f_one,
        tem_helpers.run.debug_model)
    return nothing
end

function runTEM!(output_array,
    selected_models,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_ind,
    loc_forcing,
    loc_output,
    land_init,
    f_one)
    getLocForcing!(forcing, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names, loc_forcing, loc_space_ind)
    getLocOutput!(output_array, loc_space_ind, loc_output)
    runTEMCore!(loc_output,
        selected_models,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        land_init,
        f_one,
        tem_helpers.run.spinup.run_spinup)
    return nothing
end


function parallelizeTEM!(output_array,
    selected_models,
    forcing_nt_array,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    ::Val{:threads})
    Threads.@threads for i ∈ eachindex(loc_space_inds)
        runTEM!(output_array,
            selected_models,
            forcing_nt_array,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_inds[i],
            loc_forcings[Threads.threadid()],
            loc_outputs[Threads.threadid()],
            land_init_space[i],
            f_one)
    end
    return nothing
end

"""
parallelizeTEM!((output_array, selected_models, forcing, tem_helpers, tem_spinup, tem_models, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, ::Val{:qbmap})
"""
function parallelizeTEM!(output_array,
    selected_models,
    forcing_nt_array,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one,
    ::Val{:qbmap})
    spI = 1
    qbmap(loc_space_inds) do loc_space_ind
        runTEM!(output_array,
            selected_models,
            forcing_nt_array,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_ind,
            loc_forcings[Threads.threadid()],
            loc_outputs[Threads.threadid()],
            land_init_space[spI],
            f_one)
        spI += 1
    end
    return nothing
end


function runTimeLoop!(loc_output,
    forward_models,
    loc_forcing,
    land,
    tem_helpers,
    f_one,
    ::Val{:false}) # do not debug the models
    num_time_steps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    for ts ∈ 1:num_time_steps
        f_ts = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, ts, f_one)
        land = runModelCompute(land, f_ts, forward_models, tem_helpers)
        setOutputForTimeStep!(loc_output, land, tem_helpers.vals.output_vars, ts)
    end
    return nothing
end


function runTimeLoop!(loc_output,
    forward_models,
    loc_forcing,
    land,
    tem_helpers,
    f_one,
    ::Val{:true}) # debug the models
    @show "forc"
    @time f_ts = getForcingForTimeStep(loc_forcing, tem_helpers.vals.forc_vars, 1, f_one)
    println("-------------")
    @show "each model"
    @time land = runModelCompute(land, f_ts, forward_models, tem_helpers, tem_helpers.run.debug_model)
    println("-------------")
    @show "all models"
    @time land = runModelCompute(land, f_ts, forward_models, tem_helpers)
    println("-------------")
    @show "land"
    @time setOutputForTimeStep!(loc_output, land, tem_helpers.vals.output_vars, 1)
    println("-------------")
    return nothing
end

"""
runEcosystem(selected_models, forcing, land_init, tem)
"""
function TEM!(forcing::NamedTuple,
    tem::NamedTuple)
    forcing_nt_array, output_array, _, _, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
        prepTEM(forcing, tem)
    parallelizeTEM!(output_array,
        tem_with_vals.models.forward,
        forcing_nt_array,
        tem_with_vals.helpers,
        tem_with_vals.spinup,
        tem_with_vals.models,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one,
        tem_with_vals.helpers.run.parallelization)
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
        tem_with_vals.helpers,
        tem_with_vals.spinup,
        tem_with_vals.models,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one,
        tem_with_vals.helpers.run.parallelization)
    return nothing
end
