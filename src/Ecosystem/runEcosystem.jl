export runEcosystem, runForward
export removeEmptyFields
export runPrecompute
export mapRunEcosystem
export getForcingForTimeStep

"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    for model in models
        # @show map(size,(forcing))
        # @show map(typeof,(forcing))
        out = Models.compute(model, forcing, out, tem_helpers)
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

function timeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple)
    time_steps = getForcingTimeSize(forcing)
    # time_steps = tem_helpers.dates.size
    @info "runEcosystem:: running forward time loop"
    @time res = map(1: time_steps) do ts
        f = getForcingForTimeStep(forcing, ts)
        out = runModels(f, forward_models, out, tem_helpers)
        out_filtered = filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all)
        deepcopy(out_filtered)
    end
    # push!(debugcatcherr,res)
    res
    # landWrapper(res)
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple)
    additionaldims = setdiff(keys(tem_helpers.run.loop),[:time])
    land_all = if !isempty(additionaldims)
        spacesize = values(tem_helpers.run.loop[additionaldims])
        @show spacesize
        loopvars = ntuple(i->reshape(1:i,ones(Int,i-1)...,i),length(spacesize))
        @show loopvars
        res = broadcast(loopvars...) do lI
            outnow = deepcopy(out)
            timeLoopForward(forward_models, forcing, outnow,tem_variables, tem_helpers)
        end
        push!(Sindbad.error_catcher,res)
        restuples = res.s
        for d in ndims(restuples)
            res = reduce((i,j)->cat(i,j,dims=d),res,dims=d)
        end 
        res[1]
    else
        res = timeLoopForward(forward_models, forcing, out, tem_variables, tem_helpers)
    end
    return land_all
end

"""
removeEmptyFields(tpl)
"""
function removeEmptyFields(tpl::NamedTuple)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end


"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple; spinup_forcing=nothing, run_forward=false)
    @info "runEcosystem:: running Ecosystem"
    @info "runEcosystem:: running precomputation"
    land_out=nothing
    nts = nothing
    if run_forward == false
        additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
        #@info additionaldims
        land_all = if !isempty(additionaldims)
            spacesize = values(tem.helpers.run.loop[additionaldims])
            res = broadcast(Iterators.product(Base.OneTo.(spacesize)...)) do lI
                newforcing = map(forcing) do a
                    inds = map(zip(lI,additionaldims)) do (i,lv)
                        lv=>i
                    end
                    view(a;inds...)
                    # getindex(a;inds...)
                end
                @time land_prec = runPrecompute(getForcingForTimeStep(newforcing, 1), approaches, deepcopy(land_init), tem.helpers)
                #@show first(newforcing)
                land_spin_now = land_prec
                if tem.spinup.flags.doSpinup
                    land_spin_now = runSpinup(approaches, newforcing, land_spin_now, tem; spinup_forcing=spinup_forcing)
                end
                timeLoopForward(approaches, newforcing, land_spin_now, tem.variables, tem.helpers)
            end
            #push!(Sindbad.error_catcher, res)
            nts = length(first(res))
            fullarrayoftuples = map(Iterators.product(1:nts,CartesianIndices(res))) do (its,iouter)
                res[iouter][its]
            end
            #push!(Sindbad.error_catcher, fullarrayoftuples)
            landWrapper(fullarrayoftuples)
        else
            @time land_prec = runPrecompute(getForcingForTimeStep(forcing, 1), approaches, land_init, tem.helpers)
            land_spin = deepcopy(land_prec)
            if tem.spinup.flags.doSpinup
                land_spin = runSpinup(approaches, forcing, land_prec, tem; spinup_forcing=spinup_forcing)
            end
            res = timeLoopForward(approaches, forcing, land_spin, tem.variables, tem.helpers)
            landWrapper(res)
        end
        land_out = land_all
    else
        land_spin = land_prec
        if tem.spinup.flags.doSpinup
            land_spin = runSpinup(approaches, forcing, land_prec, tem; spinup_forcing=spinup_forcing)
        end
        land_forw = runForward(approaches, forcing, land_spin, tem.variables, tem.helpers)
        # land_forw = removeEmptyFields(land_forw)
        land_out = land_forw
    end
    return land_out
end


function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end


function doRunEcosystem(args...; land_init::NamedTuple, tem::NamedTuple, forward_models::Tuple, forcing_variables::AbstractArray, spinup_forcing::Any)
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

    outcubes = mapCube(doRunEcosystem,
        (incubes...,);
        land_init=land_init,
        tem=tem,
        forward_models=forward_models,
        forcing_variables=forcing_variables,
        spinup_forcing=spinup_forcing,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache
    )
    return outcubes
end