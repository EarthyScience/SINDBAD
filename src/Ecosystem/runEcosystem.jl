export runEcosystem, runSpinup, runForward
export removeEmptyFields
export runPrecompute
export mapRunEcosystem

"""
runModels(forcing, models, out)
"""
function runModels(forcing, models, out, modelHelpers)
    for model in models
        out = Models.compute(model, forcing, out, modelHelpers)
        if modelHelpers.run.runUpdateModels
            out = Models.update(model, forcing, out, modelHelpers)
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

function runPrecompute(forcing, models, out, modelHelpers)
    for model in models
        out = Models.precompute(model, forcing, out, modelHelpers)
    end
    return out
end

function extracttimestep(forcing, ts)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

function runtimeloop(forward_models, forcing, out, modelVars, modelHelpers)
    res = map(1: modelHelpers.dates.size) do ts
        f = extracttimestep(forcing, ts)
        out = runModels(f, forward_models, out, modelHelpers)
        out_filtered = filterVariables(out, modelVars; filter_variables=!modelHelpers.run.output_all)
        deepcopy(out_filtered)
    end
    # push!(debugcatcherr,res)
    OutWrapper(res)
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models, forcing, out, modelVars, modelHelpers)
    additionaldims = setdiff(keys(modelHelpers.run.loop),[:time])
    allout = if !isempty(additionaldims)
        spacesize = values(modelHelpers.run.loop[additionaldims])
        @show spacesize
        loopvars = ntuple(i->reshape(1:i,ones(Int,i-1)...,i),length(spacesize))
        @show loopvars
        res = broadcast(loopvars...) do lI
            outnow = deepcopy(out)
            runtimeloop(forward_models, forcing, outnow,modelVars, modelHelpers)
        end
        for d in ndims(res)
            res = reducedim(catnt,res,dims=d)
        end 
        res[1]
    else
        res = runtimeloop(forward_models, forcing, out, modelVars, modelHelpers)
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
runSpinup(selectedModels, initPools, forcing, history=false; nspins=3)
"""
function runSpinup(spinup_models, forcing, out, modelHelpers; history=false, nspins=3)
    tsteps = modelHelpers.dates.size
    spinuplog = history ? [values(out)[1:length(out.pools)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(extracttimestep(forcing,t), spinup_models, out, modelHelpers)
            if history
                push!(spinuplog, values(deepcopy(out))[1:length(out.pools)])
            end
        end
    end
    return (out, spinuplog)
end

"""
runEcosystem(selectedModels, initPools, forcing, history=false; nspins=3) # forward run
"""
function runEcosystem(approaches, forcing, init_out, modelInfo; history=false, nspins=3) # forward run
    spinup_models = approaches[modelInfo.models.is_spinup.==1]

    out_prec = runPrecompute(extracttimestep(forcing,1), approaches, init_out, modelInfo.helpers)
    out_spin, spinuplog = runSpinup(spinup_models, forcing, out_prec, modelInfo.helpers; history, nspins=nspins)
    out_forw = runForward(approaches, forcing, out_spin, modelInfo.variables, modelInfo.helpers)
    # out_forw = removeEmptyFields(out_forw)
    return out_forw
end


function unpack_yax(args; modelinfo, forcing_variables, nts)
    nin = length(forcing_variables)
    nout = sum(length, modelinfo.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    #Make fillarrays for constant inputs
    # inputs = map(inputs) do i
    #     dn = AxisKeys.dimnames(i)
    #     (!in(:time, dn) && !in(:Time, dn)) ? Fill(getdata(i), nts) : getdata(i)
    # end
    return outputs, inputs
end


function rungridcell(args...; out, modelinfo, forcing_variables, nts, history=false, nspins=1)
    outputs, inputs = unpack_yax(args; modelinfo, forcing_variables, nts)
    forcing = (; Pair.(forcing_variables, inputs)...)
    outforw = runEcosystem(modelinfo.models.forward, forcing, out, modelinfo; nspins=nspins, history=history)
    i = 1
    modelvars = modelinfo.variables
    for group in keys(modelvars)
        data = outforw[group]
        for k in modelvars[group]
            @show size(outputs[i])
            @show size(data[k])
            # push!(debugcatch,(size(outputs[i]),size(data[k]), k, typeof(outputs[i]), typeof(data[k])))
            outputs[i] .= deepcopy(data[k])
            i += 1
        end
    end
end



function mapRunEcosystem(forcing, output, modelInfo)
    incubes = forcing.data
    indims = forcing.dims
    nts = forcing.n_timesteps
    forcing_variables = forcing.variables
    outdims = output.dims
    out = output.init_out

    res = mapCube(rungridcell,
        (incubes...,);
        out=out,
        modelinfo=modelInfo, #info.tem,
        forcing_variables=forcing_variables,
        nts=nts,
        indims=indims,
        outdims=outdims
    )
    return res
end