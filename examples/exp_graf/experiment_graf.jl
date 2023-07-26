using Revise
@time using Sindbad
@time using ForwardSindbad
# @time using OptimizeSindbad
noStackTrace()
domain = "africa";
optimize_it = true;
optimize_it = false;

# experiment_json = "./settings_distri/experimentW.json"
# info = getConfiguration(experiment_json);
# info = setupExperiment(info);

replace_info_spatial = Dict("experiment.domain" => domain * "_spatial",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.mapping.yaxarray" => [],
    "model_run.mapping.run_ecosystem" => ["time", "id"],
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.do_spinup" => true);

experiment_json = "../exp_graf/settings_graf/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify info
# obs = ForwardSindbad.getObservation(info);
info, forcing = getForcing(info);
output = setupOutput(info);

forc = getKeyedArrayWithNames(forcing);

GC.gc()

loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(output, forc, info.tem);

@time runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
for x ∈ 1:10
    @time runEcosystem!(output.data,
        info.tem.models.forward,
        forc,
        tem_with_vals,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
end
@profview runEcosystem!(output.data,
    info.tem.models.forward,
    forc,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

# @time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_spatial);  
@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info_spatial);
@time outcubes = runExperimentOpti(experiment_json; replace_info=replace_info_spatial);

ds = forcing.data[1];
using CairoMakie: heatmap, Colorbar, save
using AlgebraOfGraphics, DataFrames, Dates

plotdat = output.data;
for i ∈ eachindex(output.variables)
    vname = output.variables[i]
    pd = plotdat[i]
    if size(pd, 2) == 1
        fig, ax, obj = heatmap(pd[:, 1, :])
        Colorbar(fig[1, 2], obj)
        save(joinpath(info.output.figure, "afr2d_$(vname).png"), fig)
    else
        for ll ∈ 1:size(pd, 2)
            fig, ax, obj = heatmap(pd[:, ll, :])
            Colorbar(fig[1, 2], obj)
            save(joinpath(info.output.figure, "afr2d_$(vname)_$(ll).png"), fig)
        end
    end
end
