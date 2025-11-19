using Revise
using Sindbad
using YAXArrays
using ProgressMeter
toggleStackTraceNT()


info = getExperimentInfo("../exp_yax/settings_yax/experiment.json");
forcing = getForcing(info);
run_helpers = prepTEM(forcing, info);

## yax array run
@time outcubes = runTEMYax(
    info.models.forward,
    forcing,
    info);

var_pairs = info.output.variables;
data_path_base = info.output.file_info.file_prefix;
catalog_names = getVarFull.(var_pairs);
variable_names = getUniqueVarNames(var_pairs);
out_format = info.output.format;
for vn ∈ eachindex(var_pairs)
    catalog_name = catalog_names[vn]
    variable_name = variable_names[vn]
    data_yax = outcubes[vn]
    data_path = data_path_base * "_$(variable_name).$(out_format)"
    @info "saving $(data_path)"
    backend = out_format == "nc" ? :netcdf : :zarr
    savecube(outcubes[vn],data_path,driver=backend, overwrite=true)
end



### TODO the yax spatial optimization
observations = getObservation(info, forcing.helpers);

opt_params = optimizeTEMYax(forcing,
    output,
    info.tem,
    info.optimization,
    observations,
    max_cache=info.settings.experiment.exe_rules.yax_max_cache)
