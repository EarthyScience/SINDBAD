export runEcosystem
export removeEmptyFields
export runPrecompute
export mapRunEcosystem

"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl_unrolled(models; init=out) do o, model
        return o = Models.compute(model, forcing, o, tem_helpers)
        # if tem_helpers.run.runUpdateModels
        #     o = Models.update(model, forcing, o, tem_helpers)
        # end
    end
end

function runPrecompute(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl_unrolled(models; init=out) do o, model
        return o = Models.define(model, forcing, o, tem_helpers)
    end
end

@noinline function theRealtimeLoopForward(forward_models::Tuple,
    forcing::NamedTuple,
    out::NamedTuple,
    tem_variables::NamedTuple,
    tem_helpers::NamedTuple,
    time_steps,
    otype,
    oforc)
    # time_steps = 1
    # time_steps = 7200
    #f_t = getForcingForTimeStep(forcing, 1)::oforc
    #f_t = get_force_at_time_t(forcing, 1)::oforc
    res = map(1:time_steps) do ts
        #f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_t)#::oforc
        f = get_force_at_time_t(forcing, ts)
        #if ts==7864
        #    println("------------------------------------------")
        #    println("$(typeof(f) <: oforc)")
        #    println("what??")
        #    println("------------------------------------------")
        #@show pprint(out)
        #end
        #outold = out
        out = runModels(f, forward_models, out, tem_helpers)#::otype
        #@show typeof.(outold)
        #@show [typeof(onew) for onew in out]
        #@show [typeof(onew) <: typeof(outold[i]) for (i,onew) in enumerate(out)]
        #@show out[46], outold[46]
        return deepcopy(out)
        # deepcopy(filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all))
    end
    # push!(debugcatcherr,res)
    return res
    # landWrapper(res)
end

function timeLoopForward(forward_models::Tuple,
    forcing::NamedTuple,
    out::NamedTuple,
    tem_variables::NamedTuple,
    tem_helpers::NamedTuple,
    time_steps)
    #f = getForcingForTimeStep(forcing, 1)
    f = get_force_at_time_t(forcing, 1)
    #@show f
    out2 = runModels(f, forward_models, out, tem_helpers)
    res = theRealtimeLoopForward(forward_models,
        forcing,
        out2,
        tem_variables,
        tem_helpers,
        time_steps,
        typeof(out2),
        typeof(f))
    # push!(debugcatcherr,res)
    return res
    # landWrapper(res)
end

"""
removeEmptyFields(tpl)
"""
function removeEmptyFields(tpl::NamedTuple)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end

function coreEcosystem(approaches, loc_forcing, land_init, tem)
    #@info "runEcosystem:: running ecosystem"
    land_prec = runPrecompute(getForcingForTimeStep(loc_forcing, 1), approaches, land_init,
        tem.helpers)
    #@show first(newforcing)
    land_spin_now = land_prec
    if tem.helpers.run.runSpinup
        land_spin_now = runSpinup(approaches,
            loc_forcing,
            land_spin_now,
            tem.helpers,
            tem.spinup,
            tem.models,
            typeof(land_init);
            spinup_forcing=nothing)
        # land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing)
    #res = Array{NamedTuple}(undef, time_steps)
    return timeLoopForward(approaches,
        loc_forcing,
        land_spin_now,
        tem.variables,
        tem.helpers,
        time_steps)
end

function ecoLoc(approaches::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    tem::NamedTuple,
    loc_names)
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names, additionaldims)) do (loc_index, lv)
            return lv => loc_index
        end
        return view(a; inds...)
    end
    return coreEcosystem(approaches, loc_forcing, land_init, tem)
end

function fany(x,
    approaches::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    tem::NamedTuple,
    additionaldims)
    #@show "fany", Threads.threadid()
    eout = ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, x)
    return eout
end

"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple,
    forcing::NamedTuple,
    land_init::NamedTuple,
    tem::NamedTuple;
    spinup_forcing=nothing)
    #@info "runEcosystem:: running Ecosystem"
    additionaldims = setdiff(keys(tem.helpers.run.loop), [:time])
    land_all = if !isempty(additionaldims)
        spacesize = values(tem.helpers.run.loop[additionaldims])
        res = qbmap(Iterators.product(Base.OneTo.(spacesize)...)) do loc_names
            #ccall(:malloc, Cvoid, (Cint,), 0)
            #GC.safepoint()
            #@show Threads.threadid()
            return ecoLoc(approaches, forcing, deepcopy(land_init), tem, loc_names)
        end
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        nts = length(first(res))
        fullarrayoftuples =
            map(Iterators.product(1:nts, CartesianIndices(res))) do (its, iouter)
                return res[iouter][its]
            end
        res = nothing
        landWrapper(fullarrayoftuples)
    else
        res = coreEcosystem(approaches, forcing, deepcopy(land_init), tem)
        landWrapper(res)
    end
    return land_all
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
