using Revise
@time using SindbadExperiment
using Plots
toggleStackTraceNT()
domain = "africa";
optimize_it = true;
# optimize_it = false;
subsets = Dict("13" => [1, 3], "23" => [2,3])
rhc = Dict()
info = nothing
for sb in keys(subsets)
    replace_info_spatial = Dict("experiment.basics.domain" => domain * "_spatial",
        "experiment.basics.config_files.forcing" => "forcing.json",
        "experiment.flags.run_optimization" => optimize_it,
        "experiment.flags.calc_cost" => optimize_it,
        "experiment.flags.catch_model_errors" => true,
        "experiment.flags.spinup_TEM" => true,
        "experiment.flags.debug_model" => false,
        "forcing.subset.id" => subsets[sb]
        );
    @show replace_info_spatial
    experiment_json = "../exp_graf/settings_graf/experiment.json";

    info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial); # note that this will modify information from json with the replace_info
    forcing = getForcing(info);
    # observations = getObservation(info, forcing.helpers);
    # obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

    GC.gc()
    info = dropFields(info, (:settings,));
    run_helpers = prepTEM(forcing, info);
    @time runTEM!(run_helpers.space_selected_models, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)
    rhc[sb] = (; deepcopy(run_helpers)...)
end


for vi in 1:4
    oa_23_13=rhc["13"].output_array[vi][:,1,2:3];
    oa_23_23=rhc["23"].output_array[vi][:,1,:];
    heatmap(oa_23_13-oa_23_23; size=(2000, 1000))
    savefig(joinpath(info.output.dirs.figure, "afr2d_$(vi).png"))
end

rhc_sel = "13"
for rhc_sel in keys(rhc)
    for sp in 1:2
        for vi in 1:4
        ts = (rhc[rhc_sel].space_output[sp][vi] .== rhc[rhc_sel].output_array[vi][:,1,sp]) |> sum
        @show rhc_sel, sp, vi, ts
        end
    end
end
