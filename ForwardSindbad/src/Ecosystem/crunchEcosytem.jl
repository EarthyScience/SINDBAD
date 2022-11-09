export runEcosystem
export removeEmptyFields
export runPrecompute
export mapRunEcosystem
export getForcingForTimeStep




function coreEcosystem(approaches, loc_forcing, loc_output, land_init, tem)
    #@info "runEcosystem:: running ecosystem"
    land_prec = runPrecompute(getForcingForTimeStep(loc_forcing, 1), approaches, land_init, tem.helpers)
    land_spin_now = land_prec
    if tem.spinup.flags.doSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing)
    #res = Array{NamedTuple}(undef, time_steps)
    timeLoopForward(approaches, loc_forcing, loc_output, land_spin_now, tem.variables, tem.helpers, time_steps)
end


function ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, output, additionaldims, loc_names)
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end
    loc_output = map(output) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end

    coreEcosystem(approaches, loc_forcing, loc_output, land_init, tem)
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


"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function crunEcosystem(approaches::Tuple, forcing, land_init::NamedTuple, tem::NamedTuple, output; spinup_forcing=nothing)
    forcing_data = forcing.data;
    forcing_variables = forcing.variables |> collect
    forcing_new = (; Pair.(forcing_variables, forcing_data)...);
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    spacesize = values(tem.helpers.run.loop[additionaldims])
    qbmap(Iterators.product(Base.OneTo.(spacesize)...)) do loc_names
        return ecoLoc(approaches, forcing_new, deepcopy(land_init), output,tem, additionaldims, loc_names)
    end
end




"""
runModels(forcing, models, out)
"""
function runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl(models, init=out) do o,model 
        o = Models.compute(model, forcing, o, tem_helpers)
        o
    end
end


function runPrecompute(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    for model in models
        out = Models.precompute(model, forcing, out, tem_helpers)
    end
    return out
end

function setOuputT(land, outputs, tem_variables, ts)
    var_index = 1
    for group in keys(tem_variables)
        data = land[group]
        for k in tem_variables[group]
            viewcopyt(outputs[var_index],data[k], ts)
            var_index += 1
        end
    end
end

function timeLoopForward(forward_models::Tuple, forcing::NamedTuple, ar_output, out::NamedTuple,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps)
    f = getForcingForTimeStep(forcing, 1)
    out2 = runModels(f, forward_models, out, tem_helpers);
    res = theRealtimeLoopForward(forward_models, forcing, ar_output, out2, tem_variables, tem_helpers,time_steps,
    typeof(out2), typeof(f))
    res
end


@noinline function theRealtimeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, ar_output,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps, otype, oforc)
    map(1:time_steps) do ts
        f = getForcingForTimeStep(forcing, ts)::oforc
        out = runModels(f, forward_models, out, tem_helpers)::otype
        setOuputT(out, ar_output, tem_variables, ts)
    end
end


function viewcopyt(xout, xin, ts)
    if ndims(xin) == 0
            xout[ts] = xin
    else
        xout[:, ts] .= xin
        # for i in CartesianIndices(xin)
        #     xout[:,i] .= xin[i]
        # end
    end
end

