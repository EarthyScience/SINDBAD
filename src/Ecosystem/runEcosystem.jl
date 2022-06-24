export runEcosystem, runForward
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

"""
runForward(selectedModels, forcing, out, helpers)
"""
function runForward(forward_models, forcing, out, modelVars, modelHelpers)
    outtemp = map(forcing) do f
        out = runModels(f, forward_models, out, modelHelpers)
        out_filtered = filterVariables(out, modelVars; filter_variables=!modelHelpers.run.output_all)
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
runEcosystem(approaches, forcing, init_out, modelInfo; spinup_forcing=nothing)
"""
function runEcosystem(approaches, forcing, init_out, modelInfo; spinup_forcing=nothing) # forward run
    out_prec = runPrecompute(forcing[1], approaches, init_out, modelInfo.helpers)
    out_spin, spinuplog = runSpinup(approaches, forcing, out_prec, modelInfo; spinup_forcing=spinup_forcing)
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


function rungridcell(args...; out, modelinfo, forcing_variables, spinup_forcing, nts)
    outputs, inputs = unpack_yax(args; modelinfo, forcing_variables, nts)
    forcing = Table((; Pair.(forcing_variables, inputs)...))
    outforw = runEcosystem(modelinfo.models.forward, forcing, out, modelinfo; spinup_forcing=spinup_forcing)
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

function mapRunEcosystem(forcing, spinup_forcing, output, modelInfo)
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
        spinup_forcing=spinup_forcing,
        nts=nts,
        indims=indims,
        outdims=outdims
    )
    return res
end