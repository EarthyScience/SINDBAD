export runEcosystem

function timeLoopForwardVector(
    res_vec,
    forward_models,
    forcing,
    out,
    tem_helpers,
    time_steps::Int64,
    f_one
)
    for ts = 1:time_steps
        f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_one)
        out = runCompute(out, f, forward_models, tem_helpers)
        res_vec[ts] = out
    end
    return nothing
end


function timeLoopForward(
    forward_models,
    forcing,
    out,
    tem_helpers,
    time_steps::Int64,
    f_one
)
    out_stacked = map(1:time_steps) do ts
        f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_one)
        out = runCompute(out, f, forward_models, tem_helpers)
    end
    return out_stacked
end


function coreEcosystemVector(approaches,
    res_vec,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init,
    f_one)

    land_prec = runPrecompute(land_init, f_one, approaches, tem_helpers)
    land_spin_now = land_prec
    if tem_helpers.run.spinup.run_spinup
        land_spin_now = runSpinup(
            approaches,
            loc_forcing,
            land_spin_now,
            tem_helpers,
            tem_spinup,
            tem_models,
            typeof(land_init),
            f_one)
    end
    time_steps = getForcingTimeSize(loc_forcing, tem_helpers.vals.forc_vars)
    timeLoopForwardVector(
        res_vec,
        approaches,
        loc_forcing,
        land_spin_now,
        tem_helpers,
        time_steps,
        f_one)
    return nothing
end



function coreEcosystem(approaches,
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
    out_stacked = timeLoopForward(approaches,
        loc_forcing,
        land_spin_now,
        tem_helpers,
        time_steps,
        f_one)
    return out_stacked
end

function ecoLocVector(approaches,
    res_vec,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_ind,
    loc_forcing,
    land_init,
    f_one)
    getLocForcing!(forcing, tem_helpers.vals.forc_vars, tem_helpers.vals.loc_space_names, loc_forcing, loc_space_ind)
    coreEcosystemVector(approaches,
        res_vec,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        land_init,
        f_one)
    return nothing
end

function fany(x,
    approaches,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_ind,
    loc_forcing,
    land_init,
    f_one)
    #@show "fany", Threads.threadid()
    eout = ecoLoc(approaches,
        res_vec,
        forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        loc_space_ind,
        loc_forcing,
        land_init,
        f_one)
    return eout
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem(approaches,
    res_vec_space,
    forcing,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    land_init_space,
    f_one)
    #@info "runEcosystem:: running Ecosystem"
    tem_helpers = tem_with_vals.helpers
    tem_spinup = tem_with_vals.spinup
    tem_models = tem_with_vals.models
    land_all = if !isempty(loc_space_inds)
        res_out = parallelizeIt(tem_with_vals.models.forward,
            res_vec_space,
            forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_inds,
            loc_forcings,
            land_init_space,
            f_one,
            tem_with_vals.helpers.run.parallelization)
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        # landWrapper(res_vec_space)
        nts = length(first(res_out))
        fullarrayoftuples =
            map(Iterators.product(1:nts, CartesianIndices(res_out))) do (its, iouter)
                res_out[iouter][its]
            end
        # res_vec_space = nothing
        landWrapper(fullarrayoftuples)
    else
        coreEcosystemVector(approaches,
            res_vec_space,
            loc_forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            land_init,
            f_one)
        res_vec_space
    end
    return landWrapper(land_all)
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem(approaches::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    tem::NamedTuple)

    land_all = if !isempty(loc_space_inds)
        forcing_nt_array, output_array, _, _, loc_space_inds, loc_forcings, _, land_init_space, tem_with_vals, f_one =
            prepRunEcosystem(forcing, tem)
        res = parallelizeIt(tem_with_vals.models.forward,
            res_vec,
            forcing,
            tem_with_vals.helpers,
            tem_with_vals.spinup,
            tem_with_vals.models,
            loc_space_inds,
            loc_forcings,
            land_init_space,
            f_one,
            tem_with_vals.helpers.run.parallelization)
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        nts = length(first(res))
        fullarrayoftuples =
            map(Iterators.product(1:nts, CartesianIndices(res))) do (its, iouter)
                res[iouter][its]
            end
        res = nothing
        fullarrayoftuples
    else
        res = coreEcosystemVector(approaches,
            res_vec,
            loc_forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            land_init,
            f_one)
        res
    end
    return landWrapper(land_all)
end


function parallelizeIt(approaches,
    res_vec_space,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_inds,
    loc_forcings,
    land_init_space,
    f_one,
    ::Val{:threads})
    i = 1
    ltype = typeof(land_init_space[1])
    out_eco = qbmap(loc_space_inds) do loc_space_ind
        ecoLoc(approaches,
            res_vec_space[i],
            forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_ind,
            loc_forcings[Threads.threadid()],
            land_init_space[i],
            f_one)
        i = i + 1
    end
    return out_eco
end

function parallelizeIt(approaches,
    res_vec_space,
    forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    loc_space_inds,
    loc_forcings,
    land_init_space,
    f_one,
    ::Val{:qbmap})
    i = 1
    out_eco = land_init_space[1]
    qbmap(loc_space_inds) do loc_space_ind
        out_eco = ecoLoc(approaches,
            res_vec_space[i],
            forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_ind,
            loc_forcings[Threads.threadid()],
            land_init_space[i],
            f_one)
        i = i + 1
    end
    return out_eco
end
