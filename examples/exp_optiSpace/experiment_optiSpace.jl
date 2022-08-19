using Revise
using Sindbad
using ProgressMeter
noStackTrace()
domain = "DE-2";
optimize_it = true;
replace_info = Dict(
    "experiment.domain" => domain,
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => false,
);

experiment_json = "exp_optiSpace/settings_optiSpace/experiment.json";
Sindbad.eval(:(error_catcher = []))
run_output = runExperiment(experiment_json; replace_info=replace_info);



info = getConfiguration(experiment_json; replace_info=replace_info);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));

# spinup_forcing = getSpinupForcing(forcing.data, info.tem);
output = setupOutput(info);

# forward run
outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache)
#Sindbad.eval(:(debugcatcherr = []))

# optimization
observations = getObservation(info, Val(:yaxarray)); 



incubes = [forcing.data..., output.dims...];
indims = forcing.dims;
forcing_variables = forcing.variables |> collect;
outdims = output.dims;
land_init = deepcopy(output.land_init);

spinup_forcing=nothing



function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    @show args
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
    for group in keys(tem_variables)
        data = land_out[group]
        for k in tem_variables[group]
            outputs[i] .= convert(Array, deepcopy(data[k]))
            i += 1
        end
    end
end



doRunEcosystem((incubes...,); land_init=land_init, tem=tem, forward_models=forward_models,forcing_variables=forcing_variables, spinup_forcing=spinup_forcing)

