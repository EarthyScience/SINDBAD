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
    res = map(1: time_steps) do ts
        f = getForcingForTimeStep(forcing, ts)
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
function runForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple)
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
    return allout
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
runEcosystem(approaches, forcing, init_out, tem; spinup_forcing=nothing)
"""
function runEcosystem(approaches::Tuple, forcing::NamedTuple, init_out::NamedTuple, tem::NamedTuple; spinup_forcing=nothing, run_forward=false)
    @info "runEcosystem:: running Ecosystem"
    @time begin
        out_prec = runPrecompute(getForcingForTimeStep(forcing, 1), approaches, init_out, tem.helpers)
        outEco=nothing
        if run_forward == false
            additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
            allout = if !isempty(additionaldims)
                spacesize = values(tem.helpers.run.loop[additionaldims])
                @show spacesize
                loopvars = ntuple(i->reshape(1:i,ones(Int,i-1)...,i),length(spacesize))
                @show loopvars
                res = broadcast(loopvars...) do lI
                    outnow_spin = deepcopy(out_prec)
                    if tem.spinup.flags.doSpinup
                        outnow_spin = runSpinup(approaches, forcing, outnow_spin, tem; spinup_forcing=spinup_forcing)
                    end
                    timeLoopForward(forward_models, forcing, outnow_spin, tem.variables, tem.helpers)
                end
                for d in ndims(res)
                    res = reducedim(catnt,res,dims=d)
                end 
                res[1]
            else
                out_spin = out_prec
                if tem.spinup.flags.doSpinup
                    out_spin = runSpinup(approaches, forcing, out_prec, tem; spinup_forcing=spinup_forcing)
                end
                res = timeLoopForward(approaches, forcing, out_spin, tem.variables, tem.helpers)
            end
            outEco = allout
        else
            out_spin = out_prec
            if tem.spinup.flags.doSpinup
                out_spin = runSpinup(approaches, forcing, out_prec, tem; spinup_forcing=spinup_forcing)
            end
            out_forw = runForward(approaches, forcing, out_spin, tem.variables, tem.helpers)
            # out_forw = removeEmptyFields(out_forw)
            outEco = out_forw
        end
    end
    return outEco
end


function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end


function doRunEcosystem(args...; out::NamedTuple, tem::NamedTuple, forward_models::Tuple, forcing_variables::AbstractArray, spinup_forcing::Any)
    outputs, inputs = unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    outforw = runEcosystem(forward_models, forcing, out, tem; spinup_forcing=spinup_forcing)
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


function mapRunEcosystem(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, forward_models::Tuple; spinup_forcing=nothing, max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = forcing.variables |> collect
    outdims = output.dims
    out = deepcopy(output.init_out)

    outcubes = mapCube(doRunEcosystem,
        (incubes...,);
        out=out,
        tem=tem,
        forward_models=forward_models,
        forcing_variables=forcing_variables,
        spinup_forcing=spinup_forcing,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache
    )
    #TODO: save the output cubes
    return (; Pair.(output.variables, outcubes)...)
end