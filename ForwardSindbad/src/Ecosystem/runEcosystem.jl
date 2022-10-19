export runEcosystem
export removeEmptyFields
export runPrecompute
export mapRunEcosystem
export getForcingForTimeStep

"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    for model in models
        # println("---------")
        out = Models.compute(model, forcing, out, tem_helpers)
        # @show model
        # println("---------")
        if tem_helpers.run.runUpdateModels
            out = Models.update(model, forcing, out, tem_helpers)
        end
    end
    return out
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

function timeLoopForward(forward_models::Tuple, forcing::NamedTuple, in_out::NamedTuple,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, res, time_steps)
    #time_steps = getForcingTimeSize(forcing)
    # time_steps = tem_helpers.dates.size
    #@info "runEcosystem:: running forward time loop"
    #res = Array{NamedTuple}(time_steps, undef)
    #res = Array{NamedTuple}(undef, time_steps)
    #res = map(1: time_steps) do ts
    #    f = getForcingForTimeStep(forcing, ts)
    #    out = runModels(f, forward_models, out, tem_helpers)
    #    out_filtered = filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all)
    #    deepcopy(out_filtered)
    #end
    for ts in 1:time_steps
        f = getForcingForTimeStep(forcing, ts)
        out = runModels(f, forward_models, deepcopy(in_out), tem_helpers)
        out_filtered = filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all)
        res[ts] =  deepcopy(out_filtered)
        out_filtered = nothing
        out = nothing
        # GC.gc()
    end
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
    res = Array{NamedTuple}(undef, time_steps)
    tf = timeLoopForward(approaches, loc_forcing, land_spin_now, tem.variables, tem.helpers, res,  time_steps)
    tf
end

function ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims, loc_names)
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end
    coreEcosystem(approaches, loc_forcing, deepcopy(land_init), tem)
end

function fany(x, approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims)
    @show "fany", Threads.threadid()
    @time oute = ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims, x)
    oute
end

"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple; spinup_forcing=nothing)
    #@info "runEcosystem:: running Ecosystem"
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    land_all = if !isempty(additionaldims)
        spacesize = values(tem.helpers.run.loop[additionaldims])
        #res = qbmap(Iterators.product(Base.OneTo.(spacesize)...)) do loc_names
        #    @show Threads.threadid()
        #    ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims, loc_names)
        #end
        # res_site = Array{NamedTuple}(undef, spacesize)
        # tmp = x -> fany(x,approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims)
        # @Threads for site in 1:spacesize
        #     res_site[site] = tmp(site)
        # end

        res = qbmap(x -> fany(x,approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, additionaldims), Iterators.product(Base.OneTo.(spacesize)...))

        nts = length(first(res))
        fullarrayoftuples = map(Iterators.product(1:nts,CartesianIndices(res))) do (its,iouter)
            res[iouter][its]
        end
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
    @show "doRun", Threads.threadid()
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
        nthreads = [1],
    )
    return outcubes
end