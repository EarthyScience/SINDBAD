export runEcosystem
export removeEmptyFields
export runPrecompute
export mapRunEcosystem

"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl_unrolled(models; init=out) do o, model
        o = Models.compute(model, forcing, o, tem_helpers)
    end
end

function runPrecompute(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl_unrolled(models; init=out) do o, model
        o = Models.define(model, forcing, o, tem_helpers)
    end
end


function timeLoopForward(
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
        out = runModels!(out, f, forward_models, tem_helpers)
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
        out = runModels!(out, f, forward_models, tem_helpers)
    end
    return out_stacked
end

"""
removeEmptyFields(tpl)
"""
function removeEmptyFields(tpl::NamedTuple)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end


function coreEcosystem(approaches,
    res_vec,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    land_init,
    f_one)

    land_prec = runPrecompute!(land_init, f_one, approaches, tem_helpers)
    land_spin_now = land_prec
    if tem_helpers.run.runSpinup
        land_spin_now = runSpinup(
            approaches,
            loc_forcing,
            land_spin_now,
            tem_helpers,
            tem_spinup,
            tem_models,
            typeof(land_init),
            f_one,
            spinup_forcing=nothing)
    end
    time_steps = tem_helpers.dates.size
    timeLoopForward(
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
    land_prec = runPrecompute!(land_init, f_one, approaches, tem_helpers)
    land_spin_now = land_prec
    # land_spin_now = land_init

    if tem_helpers.run.runSpinup
        land_spin_now = runSpinup(approaches,
            loc_forcing,
            land_spin_now,
            tem_helpers,
            tem_spinup,
            tem_models,
            typeof(land_init),
            f_one;
            spinup_forcing=nothing)
    end
    time_steps = tem_helpers.dates.size
    out_stacked = timeLoopForward(approaches,
        loc_forcing,
        land_spin_now,
        tem_helpers,
        time_steps,
        f_one)
    return out_stacked
end

function ecoLoc(approaches,
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
    coreEcosystem(approaches,
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
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches,
    forcing,
    tem_vals,
    loc_space_inds,
    loc_forcings,
    land_init_space,
    res_vec_space,
    f_one)
    #@info "runEcosystem:: running Ecosystem"
    tem_helpers = tem_vals.helpers
    tem_spinup = tem_vals.spinup
    tem_models = tem_vals.models
    land_all = if !isempty(loc_space_inds)
        res_out = parallelizeIt(tem_vals.models.forward,
            res_vec_space,
            forcing,
            tem_helpers,
            tem_spinup,
            tem_models,
            loc_space_inds,
            loc_forcings,
            land_init_space,
            f_one,
            tem_vals.helpers.run.parallelization)
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        # landWrapper(res_vec_space)
        nts = length(first(res_out))
        fullarrayoftuples =
            map(Iterators.product(1:nts, CartesianIndices(res_out))) do (its, iouter)
                return res_out[iouter][its]
            end
        # res_vec_space = nothing
        landWrapper(fullarrayoftuples)
    else
        coreEcosystem(approaches,
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
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    tem::NamedTuple,
    loc_space_inds;
    spinup_forcing=nothing)
    #@info "runEcosystem:: running Ecosystem"

    land_all = if !isempty(loc_space_inds)
        _, _, loc_space_inds, loc_forcings, _, land_init_space, tem_vals, f_one =
            prepRunEcosystem(output, forcing, tem)
        res = parallelizeIt(tem_vals.models.forward,
            res_vec,
            forcing,
            tem_vals.helpers,
            tem_vals.spinup,
            tem_vals.models,
            loc_space_inds,
            loc_forcings,
            land_init_space,
            f_one,
            tem_vals.helpers.run.parallelization)
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        nts = length(first(res))
        fullarrayoftuples =
            map(Iterators.product(1:nts, CartesianIndices(res))) do (its, iouter)
                return res[iouter][its]
            end
        res = nothing
        fullarrayoftuples
    else
        res = coreEcosystem(approaches,
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
function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end

function doRunEcosystem(args...;
    land_init::NamedTuple,
    tem::NamedTuple,
    forward_models::Tuple,
    forcing_variables::AbstractArray,
    spinup_forcing::Any)
    #@show "doRun", Threads.threadid()
    outputs, inputs = unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    land_out = runEcosystem(forward_models, forcing, land_init, tem; spinup_forcing=spinup_forcing)
    i = 1
    tem_variables = tem.variables
    for group ∈ keys(tem_variables)
        data = land_out[group]
        for k ∈ tem_variables[group]
            viewcopy(outputs[i], data[k])
            i += 1
        end
    end
end

function viewcopy(xout, xin)
    if ndims(xout) == ndims(xin)
        for i ∈ eachindex(xin)
            xout[i] = xin[i][1]
        end
    else
        for i ∈ CartesianIndices(xin)
            xout[:, i] .= xin[i]
        end
    end
end

function mapRunEcosystem(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    forward_models::Tuple;
    spinup_forcing=nothing,
    max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = collect(forcing.variables)
    outdims = output.dims
    land_init = deepcopy(output.land_init)
    #additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    #nthreads = 1 ? !isempty(additionaldims) : Threads.nthreads()

    outcubes = mapCube(doRunEcosystem,
        (incubes...,);
        land_init=land_init,
        tem=tem,
        forward_models=forward_models,
        forcing_variables=forcing_variables,
        spinup_forcing=spinup_forcing,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache,
        ispar=true
        #nthreads = [1],
    )
    return outcubes
end
