using Revise
using SindbadData
using SindbadTEM
using ProgressMeter
toggleStackTraceNT()

info = getExperimentInfo("../exp_yax/settings_yax/experiment.json"); # note that this will modify information from json with the replace_info

forcing = getForcing(info);


# forcing/input information
incubes = forcing.data;
indims = forcing.dims;
forcing_variables = collect(forcing.variables);

# information for running model
output = prepTEMOut(info, forcing.helpers);
run_helpers = prepTEM(forcing, info);
outdims = run_helpers.out_dims;
land_init = deepcopy(run_helpers.land_init);
out_variables = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars);

@time outcubes = runTEMYax(
    info.tem.models.forward,
    forcing,
    info);

# optimization
observations = getObservation(info, forcing.helpers);

opt_params = optimizeTEMYax(forcing,
    output,
    info.tem,
    info.optim,
    observations,
    max_cache=info.experiment.exe_rules.yax_max_cache)
