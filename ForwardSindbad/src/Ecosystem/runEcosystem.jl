export runEcosystem
export removeEmptyFields
export runPrecompute
export mapRunEcosystem
export getForcingForTimeStep

"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl(models, init=out) do o,model 
        #@show typeof(o)
        #@show typeof(model)
        #@time o = Models.compute(model, forcing, o, tem_helpers)
        o = Models.compute(model, forcing, o, tem_helpers)
        # if tem_helpers.run.runUpdateModels
        #     o = Models.update(model, forcing, o, tem_helpers)
        # end
        o
    end
end


"""
filterVariables(out::NamedTuple, varsinfo; filter_variables=true)
"""
function filterVariables(out::NamedTuple, varsinfo::NamedTuple; filter_variables=true)
    if !filter_variables
        fout=out
    else
        fout = (;)
        for k in keys(varsinfo)
            v = getfield(varsinfo, k)
            # fout = setTupleField(fout, (k, v, getfield(out, k)))
            fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
        end
    end
    return fout
end

function runPrecompute(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    for model in models
        out = Models.precompute(model, forcing, out, tem_helpers)
    end
    return out
end

function getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v in forcing
        if in(:time, AxisKeys.dimnames(v)) 
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

function getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

@noinline function theRealtimeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps,otype, oforc)
    res = map(1:1) do ts
        f = getForcingForTimeStep(forcing, ts)::oforc
        out = runModels(f, forward_models, out, tem_helpers)::otype
        deepcopy(filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all))
    end
    # push!(debugcatcherr,res)
    res
    # landWrapper(res)
end

function timeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps)
    f = getForcingForTimeStep(forcing, 1)
    out2 = runModels(f, forward_models, out, tem_helpers);
    res = theRealtimeLoopForward(forward_models, forcing, out2, tem_variables, tem_helpers,time_steps,
    typeof(out2), typeof(f))
    # push!(debugcatcherr,res)
    res
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
    land_prec = runPrecompute(getForcingForTimeStep(loc_forcing, 1), approaches, land_init, tem.helpers)
    #@show first(newforcing)
    land_spin_now = land_prec
    if tem.spinup.flags.doSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing)
    #res = Array{NamedTuple}(undef, time_steps)
    timeLoopForward(approaches, loc_forcing, land_spin_now, tem.variables, tem.helpers, time_steps)
end

function ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims, loc_names)
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end
    coreEcosystem(approaches, loc_forcing, land_init, tem)
end

function fany(x, approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims)
    #@show "fany", Threads.threadid()
    eout = ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims, x)
    eout
end

"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple; spinup_forcing=nothing)
    #@info "runEcosystem:: running Ecosystem"
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    land_all = if !isempty(additionaldims)
        spacesize = values(tem.helpers.run.loop[additionaldims])
        res = qbmap(Iterators.product(Base.OneTo.(spacesize)...)) do loc_names
            #ccall(:malloc, Cvoid, (Cint,), 0)
            #GC.safepoint()
            #@show Threads.threadid()
            return ecoLoc(approaches, forcing, deepcopy(land_init), tem, additionaldims, loc_names)
        end
        #res = qbmap(x -> fany(x,approaches, forcing, deepcopy(land_init), tem, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))
        nts = length(first(res))
        fullarrayoftuples = map(Iterators.product(1:nts,CartesianIndices(res))) do (its,iouter)
            res[iouter][its]
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


function doRunEcosystem(args...; land_init::NamedTuple, tem::NamedTuple, forward_models::Tuple, forcing_variables::AbstractArray, spinup_forcing::Any)
    #@show "doRun", Threads.threadid()
    outputs, inputs = unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    land_out = runEcosystem(forward_models, forcing, land_init, tem; spinup_forcing=spinup_forcing)
    i = 1
    tem_variables = tem.variables
    # push!(Sindbad.error_catcher,(;outputs,tem_variables,land_out))
    for group in keys(tem_variables)
        data = land_out[group]
        for k in tem_variables[group]
            viewcopy(outputs[i],data[k])
            i += 1
        end
    end
end


function viewcopy(xout, xin)
    if ndims(xout) == ndims(xin)
        for i in eachindex(xin)
            xout[i] = xin[i][1]
        end
    else
        for i in CartesianIndices(xin)
            xout[:,i] .= xin[i]
        end
    end
end

function mapRunEcosystem(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, forward_models::Tuple; spinup_forcing=nothing, max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = forcing.variables |> collect
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
        ispar = true,
        #nthreads = [1],
    )
    return outcubes
end