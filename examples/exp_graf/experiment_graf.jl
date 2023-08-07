using Revise
@time using Sindbad
@time using ForwardSindbad
@time using OptimizeSindbad
noStackTrace()
domain = "africa";
optimize_it = true;
# optimize_it = false;

# experiment_json = "./settings_distri/experimentW.json"
# info = getConfiguration(experiment_json);
# info = setupExperiment(info);

replace_info_spatial = Dict("experiment.domain" => domain * "_spatial",
    "experiment.configuration_files.forcing" => "forcing.json",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.mapping.yaxarray" => [],
    "model_run.mapping.run_ecosystem" => ["time", "id"],
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.do_spinup" => true);

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
obs_array = getArray(observations);

GC.gc()

forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info);

@time TEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)

for x ∈ 1:10
    @time TEM!(info.tem.models.forward,
        forcing_nt_array,
        loc_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        loc_space_inds,
        tem_with_vals)
end

getLossVector(obs_array, output_array, info.optim.cost_options)

@time output_default = runExperimentForward(experiment_json; replace_info=replace_info_spatial);
@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);

ds = forcing.data[1];
using Plots
plotdat = output_array;
out_vars = valToSymbol(tem_with_vals.helpers.vals.output_vars)
for i ∈ eachindex(out_vars)
    v = out_vars[i]
    vinfo = getVariableInfo(v, info.model_run.time.model_timestep)
    vname = vinfo["standard_name"]
    pd = plotdat[i]
    if size(pd, 2) == 1
        heatmap(pd[:, 1, :])
        # Colorbar(fig[1, 2], obj)
        savefig(joinpath(info.output.figure, "afr2d_$(vname).png"))
    else
        for ll ∈ 1:size(pd, 2)
            heatmap(pd[:, 1, :])
            # Colorbar(fig[1, 2], obj)
            savefig(joinpath(info.output.figure, "afr2d_$(vname)_$(ll).png"))
        end
    end
end
