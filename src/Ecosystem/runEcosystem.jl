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
        # out = Models.update(model, forcing, out, modelHelpers)
    end
    return out
end

"""
filterVariables(out::NamedTuple, varsinfo)
"""
function filterVariables(out::NamedTuple, varsinfo)
    fout = (;)
    for k in keys(varsinfo)
        v = getfield(varsinfo, k)
        # fout = setTupleField(fout, (k, v, getfield(out, k)))
        fout = setTupleField(fout, (k, NamedTuple{v}(getfield(out, k))))
    end
    return fout
end

function runPrecompute(forcing, models, out, modelHelpers)
    for model in models
        out = Models.precompute(model, forcing, out, modelHelpers)
    end
    return out
end

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models, forcing, out, modelVars, modelHelpers)
    outtemp = map(forcing) do f
        out = runModels(f, forward_models, out, modelHelpers)
        out_filtered = filterVariables(out, modelVars)
        deepcopy(out_filtered)
    end
    out_temporal = columntable(outtemp)
    # out_temporal = columntable(outtemp)
    return out_temporal
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
    tsteps = size(forcing, 1)
    spinuplog = history ? [values(out)[1:length(out.pools)]] : nothing
    for j in 1:nspins
        for t in 1:tsteps
            out = runModels(forcing[t], spinup_models, out, modelHelpers)
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
    out_prec = runPrecompute(forcing[1], approaches, init_out, modelInfo.helpers)
    out_spin, spinuplog = runSpinup(spinup_models, forcing, out_prec, modelInfo.helpers; history, nspins=nspins)
    out_forw = runForward(approaches, forcing, out_spin, modelInfo.variables, modelInfo.helpers)
    out_forw = removeEmptyFields(out_forw)
    return out_forw
end


function unpack_yax(args; modelinfo, forcing_variables, nts)
    nin = length(forcing_variables)
    nout = sum(length, modelinfo.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    #Make fillarrays for constant inputs
    inputs = map(inputs) do i
        dn = AxisKeys.dimnames(i)
        (!in(:time, dn) && !in(:Time, dn)) ? Fill(getdata(i), nts) : getdata(i)
    end
    return outputs, inputs
end


function rungridcell(args...; out, modelinfo, forcing_variables, nts, history=false, nspins=1)
    outputs, inputs = unpack_yax(args; modelinfo, forcing_variables, nts)
    forcing = Table((; Pair.(forcing_variables, inputs)...))
    outforw = runEcosystem(modelinfo.models.forward, forcing, out, modelinfo; nspins=nspins, history=history)
    i = 1
    modelvars = modelinfo.variables
    for group in keys(modelvars)
        data = columntable(outforw[group])
        for k in modelvars[group]
            if eltype(data[k]) <: AbstractArray
                for j in axes(outputs[i], 1)
                    outputs[i][j, :] = data[k][j]
                end
            else
                outputs[i][:] .= data[k]
            end
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