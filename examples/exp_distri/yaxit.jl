using YAXArrays
using Sindbad
using ForwardSindbad
using HybridSindbad
using ThreadPools
using AxisKeys
# copy data from 
# rsync -avz lalonso@atacama:/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr
Sindbad.noStackTrace()
experiment_json = "./settings_distri/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
ds = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_forcing.zarr/";
# ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
forcing = HybridSindbad.getForcing(info, ds, Val{:zarr}());
using Zarr
ds = YAXArrays.open_dataset(zopen(ds));

chunkeddata = setchunks.(forcing.data, ((site=1,),));

forcing = (; forcing..., data = (chunkeddata));
# Sindbad.error_catcher
Sindbad.eval(:(error_catcher = []));

output = ForwardSindbad.setupOutput(info);
# outcubes = yx_runEcosystem(info.tem.models.forward, forcing, output.land_init, info.tem, output.dims);

# @time land_init = createLandInit(info.tem);

@time outcubes = yx_mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward;
    max_cache=1e9);




function yx_ecoLoc(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, outcubes, additionaldims, loc_names)
    # @show forcing
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        # @show typeof(forcing), typeof(a), inds
        # (typeof(forcing), typeof(a), inds) = (NT, KeyedArray{Float64, 2, NamedDimsArray{(:depth, :site), Float64, 2, Matrix{Float64}}, T}, [:site => 1])
        view(a;inds...)
    end
    # @show loc_forcing
    loc_output = map(outcubes) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            loc_index
        end
        tmp = nothing
        if ndims(a) == 2
            tmp = view(a, :, inds..., 1)
        else
            tmp = view(a, :, :, inds..., 1)
        end
        # @show inds,ndims(a), size(tmp), typeof(tmp)
        # (inds, ndims(a), size(tmp), typeof(tmp)) = ([1], 2, (14245,), SubArray{Union{Missing, Float64}, 1, Base.ReshapedArray{Union{Missing, Float64}, 3, Matrix{Union{Missing, Float64}}, NT}, T, true})
        tmp
    end
    # @show loc_output
    land_init = createLandInit(tem);
    yx_coreEcosystem(approaches, loc_forcing, land_init, tem, loc_output)
end


function yx_setOuputT(land, outputs, tem_variables, ts)
    var_index = 1
    for group in keys(tem_variables)
        data = land[group]
        for k in tem_variables[group]
            # @show group, k
            yx_viewcopyt(outputs[var_index],data[k], ts)
            var_index += 1
        end
    end
end


function yx_viewcopyt(xout, xin, ts)
    # @show size(xout),xin, ts
    if ndims(xin) == 0
        # @show "Idonumber"
        xout[ts] = xin
        # @show xout[ts]
    else
        # @show "Idoarray"
        if length(xin) == 1
            xout[ts] = xin[1]
        else
            xout[:, ts] .= xin
        end
    end
end
    
    
"""
runModels(forcing, models, out)
"""
function yx_runModels(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    return foldl(models, init=out) do o,model 
        o = Models.compute(model, forcing, o, tem_helpers)
        o
    end
end


function yx_runPrecompute(forcing::NamedTuple, models::Tuple, out::NamedTuple, tem_helpers::NamedTuple)
    for model in models
        out = Models.precompute(model, forcing, out, tem_helpers)
    end
    return out
end

function yx_getForcingTimeSize(forcing::NamedTuple)
    forcingTimeSize = 1
    for v in forcing
        if in(:time, AxisKeys.dimnames(v)) 
            forcingTimeSize = size(v, 1)
        end
    end
    return forcingTimeSize
end

function yx_getForcingForTimeStep(forcing::NamedTuple, ts::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
    end
end

@noinline function yx_theRealtimeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps, loc_output, otype, oforc)
    map(1:time_steps) do ts
        f = yx_getForcingForTimeStep(forcing, ts)::oforc
        out = yx_runModels(f, forward_models, out, tem_helpers)::otype
        yx_setOuputT(out, loc_output, tem_variables, ts)
    end
end

function yx_timeLoopForward(forward_models::Tuple, forcing::NamedTuple, out::NamedTuple,
    tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps, loc_output)
    f = yx_getForcingForTimeStep(forcing, 1)
    out2 = yx_runModels(f, forward_models, out, tem_helpers);
    yx_theRealtimeLoopForward(forward_models, forcing, out2, tem_variables, tem_helpers, time_steps, loc_output, typeof(out2), typeof(f))
end



function yx_coreEcosystem(approaches, loc_forcing, land_init, tem, loc_output)
    #@info "runEcosystem:: running ecosystem"
    land_prec = yx_runPrecompute(getForcingForTimeStep(loc_forcing, 1), approaches, land_init, tem.helpers)
    land_spin_now = land_prec
    # if tem.spinup.flags.doSpinup
    #     land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    # end
    time_steps = yx_getForcingTimeSize(loc_forcing)
    yx_timeLoopForward(approaches, loc_forcing, land_spin_now, tem.variables, tem.helpers, time_steps, loc_output)
end
"""
runEcosystem(approaches, forcing, land_init, tem; spinup_forcing=nothing)
"""
function yx_runEcosystem(approaches::Tuple, forcing::NamedTuple, land_init::NamedTuple, tem::NamedTuple, outcubes; spinup_forcing=nothing)
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    if !isempty(additionaldims)
        spacesize = values(tem.helpers.run.loop[additionaldims])
        qbmap(Iterators.product(Base.OneTo.(spacesize)...)) do loc_names
            return yx_ecoLoc(approaches, forcing, land_init, tem, outcubes,additionaldims, loc_names)
        end
    else
        yx_coreEcosystem(approaches, forcing, deepcopy(land_init), tem, outcubes)
    end
end


function yx_unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end


function yx_doRunEcosystem(args...; land_init::NamedTuple, tem::NamedTuple, forward_models::Tuple, forcing_variables::AbstractArray, spinup_forcing::Any)
    #@show "doRun", Threads.threadid()
    outputs, inputs = yx_unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    # push!(Sindbad.error_catcher,(;outputs,forcing, inputs))
    yx_runEcosystem(forward_models, forcing, land_init, tem, outputs; spinup_forcing=spinup_forcing)
    outputs
end


function yx_mapRunEcosystem(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, forward_models::Tuple; spinup_forcing=nothing, max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = forcing.variables |> collect
    outdims = output.dims
    land_init = deepcopy(output.land_init)
    #additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    #nthreads = 1 ? !isempty(additionaldims) : Threads.nthreads()

    outcubes = mapCube(yx_doRunEcosystem,
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