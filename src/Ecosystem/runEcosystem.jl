export runEcosystem, runForward
export removeEmptyFields
export runPrecompute
export mapRunEcosystem
export getForcingTimeStep

"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, tem_helpers)
    for model in models
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
function filterVariables(out::NamedTuple, varsinfo; filter_variables=true)
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

function runPrecompute(forcing, models, out, tem_helpers)
    for model in models
        out = Models.precompute(model, forcing, out, tem_helpers)
    end
    return out
end

function getForcingTimeStep(forcing, ts)
    @show "GFS", typeof(forcing), typeof(forcing.ambCO2), AxisKeys.dimnames(forcing.Tair)
    map(forcing) do v
        @show typeof(forcing), typeof(v)
        # error("fuck it")
        push!(debugcatcherr,v)
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

function timeLoopForward(forward_models, forcing, out, tem_variables, tem_helpers)
    res = map(1: tem_helpers.dates.size) do ts
        f = getForcingTimeStep(forcing, ts)
        out = runModels(f, forward_models, out, tem_helpers)
        out_filtered = filterVariables(out, tem_variables; filter_variables=!tem_helpers.run.output_all)
        deepcopy(out_filtered)
    end
    # push!(debugcatcherr,res)
    OutWrapper(res)
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models, forcing, out, tem_variables, tem_helpers)
    additionaldims = setdiff(keys(tem_helpers.run.loop),[:time])
    allout = if !isempty(additionaldims)
        spacesize = values(tem_helpers.run.loop[additionaldims])
        @show spacesize
        loopvars = ntuple(i->reshape(1:i,ones(Int,i-1)...,i),length(spacesize))
        @show loopvars
        res = broadcast(loopvars...) do lI
            outnow = deepcopy(out)
            timeLoopForward(forward_models, forcing, outnow,tem_variables, tem_helpers)
        end
        for d in ndims(res)
            res = reducedim(catnt,res,dims=d)
        end 
        res[1]
    else
        res = timeLoopForward(forward_models, forcing, out, tem_variables, tem_helpers)
    end
    # push!(debugcatch, allout)
    # out_temporal = columntable(outtemp)
    return allout
    # return outtemp[1]
end

"""
removeEmptyFields(tpl)
"""
function removeEmptyFields(tpl)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end


"""
runEcosystem(approaches, forcing, init_out, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches, forcing, init_out, tem; spinup_forcing=nothing)
    @show "RE", typeof(forcing), typeof(forcing.Tair), AxisKeys.dimnames(forcing.Tair)
    out_prec = runPrecompute(getForcingTimeStep(forcing, 1), approaches, init_out, tem.helpers)
    out_spin = out_prec
    if tem.spinup.flags.doSpinup
        out_spin = runSpinup(approaches, forcing, out_prec, tem; spinup_forcing=spinup_forcing)
    end
    out_forw = runForward(approaches, forcing, out_spin, tem.variables, tem.helpers)
    # out_forw = removeEmptyFields(out_forw)
    return out_forw
end


function unpackYax(args; tem, forcing_variables)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end


function runGridCell(args...; out, tem, forcing_variables, spinup_forcing)
    outputs, inputs = unpackYax(args; tem, forcing_variables)
    @show typeof(inputs)
    forcing = Table((; Pair.(forcing_variables, inputs)...))
    @show typeof(forcing), typeof(forcing.Tair), AxisKeys.dimnames(forcing.Tair)
    outforw = runEcosystem(tem.models.forward, forcing, out, tem; spinup_forcing=spinup_forcing)
    i = 1
    tem_variables = tem.variables
    for group in keys(tem_variables)
        data = outforw[group]
        for k in tem_variables[group]
            outputs[i] .= convert(Array, deepcopy(data[k]))
            i += 1
        end
    end
end

function mapRunEcosystem(forcing, spinup_forcing, output, tem)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = forcing.variables
    outdims = output.dims
    out = output.init_out

    res = mapCube(runGridCell,
        (incubes...,);
        out=out,
        tem=tem,
        forcing_variables=forcing_variables,
        spinup_forcing=spinup_forcing,
        indims=indims,
        outdims=outdims
    )
    return res
end