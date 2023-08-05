export coreEcosystem!
export ecoLoc!
export runEcosystem!

function coreEcosystem!(loc_output,
    approaches,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init,
    f_one)
    land_prec = runPrecompute(land_init, f_one, approaches, tem_helpers)
    land_spin_now = land_prec
    # land_spin_now = land_init

    if tem_helpers.run.spinup.run_spinup
        land_spin_now = runSpinup(approaches,
            loc_forcing,
            land_spin_now,
            tem_helpers,
            tem_spinup,
            tem_models,
            typeof(land_init),
            f_one)
    end
    time_steps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    timeLoopForward!(loc_output,
        approaches,
        loc_forcing,
        land_spin_now,
        tem_helpers,
        time_steps,
        f_one)
    return nothing
end

function ecoLoc!(output_array,
    approaches,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_ind,
    loc_forcing,
    loc_output,
    land_init,
    f_one)
    getLocOutput!(output_array, loc_space_ind, loc_output)
    getLocForcing!(forcing, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names, loc_forcing, loc_space_ind)
    coreEcosystem!(loc_output,
        approaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        land_init,
        f_one)
    return nothing
end


function parallelizeIt!(output_array,
    approaches,
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
        ecoLoc!(output_array,
            approaches,
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
parallelizeIt!((output_array, approaches, forcing, tem_helpers, tem_spinup, tem_models, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, ::Val{:qbmap})
"""
function parallelizeIt!(output_array,
    approaches,
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
        ecoLoc!(output_array,
            approaches,
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

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(forcing::NamedTuple,
    tem::NamedTuple)
    forcing_nt_array, output_array, _, _, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
        prepRunEcosystem(forcing, tem)
    parallelizeIt!(output_array,
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
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(output_array::AbstractArray,
    approaches,
    forcing_nt_array::NamedTuple,
    tem_with_vals::NamedTuple,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    parallelizeIt!(output_array,
        approaches,
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


function timeLoopForward!(loc_output,
    forward_models,
    forcing,
    out,
    tem_helpers,
    time_steps::Int64,
    f_one)
    if tem_helpers.run.debug_model
        @show "forc"
        @time f = getForcingForTimeStep(forcing, tem_helpers.vals.forc_vars, 1, f_one)
        println("-------------")
        @show "each model"
        @time out = runCompute(out, f, forward_models, tem_helpers, tem_helpers.vals.debug_model)
        println("-------------")
        @show "all models"
        @time out = runCompute(out, f, forward_models, tem_helpers)
        println("-------------")
        @show "out"
        @time setOutputT!(loc_output, out, tem_helpers.vals.output_vars, 1)
        println("-------------")
    else
        for ts ∈ 1:time_steps
            f = getForcingForTimeStep(forcing, tem_helpers.vals.forc_vars, ts, f_one)
            out = runCompute(out, f, forward_models, tem_helpers)#::otype
            setOutputT!(loc_output, out, tem_helpers.vals.output_vars, ts)
        end
    end
    return nothing
end