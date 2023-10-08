using Revise
using SindbadData
using SindbadTEM
using ProgressMeter
toggleStackTraceNT()


info = getExperimentInfo("../exp_yax/settings_yax/experiment.json");
forcing = getForcing(info);

## yax array run
@time outcubes = runTEMYax(
    info.tem.models.forward,
    forcing,
    info);

## normal array run
replace_info = Dict("experiment.exe_rules.land_output_type" => "array");
info = getExperimentInfo("../exp_yax/settings_yax/experiment.json"; replace_info=replace_info);
runTEM!(forcing, info);


### TODO the yax spatial optimization
observations = getObservation(info, forcing.helpers);

opt_params = optimizeTEMYax(forcing,
    output,
    info.tem,
    info.optim,
    observations,
    max_cache=info.experiment.exe_rules.yax_max_cache)
