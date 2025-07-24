# ENV["JULIA_NUM_PRECOMPILE_TASKS"] = "1"
using SindbadTEM
using SindbadData
using SindbadSetup
using SindbadML.JLD2

include("fire_models.jl");

experiment_output = "ALL_025"
remote_local = "/Net/Groups/BGI/tscratch/lalonso/"
remote_root = joinpath(remote_local, experiment_output)
mkpath(remote_root)

domain = "Global";
replace_info_spatial = Dict(
    "experiment.model_output.path" => remote_root,
    "experiment.basics.domain" => domain * "_spatial",
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.run_optimization" => false,
    "info.settings.experiment.flags.calc_cost" => false,
    "model_structure.sindbad_models" => fire_models
    );

experiment_json = "../exp_global_runs/settings_global_runs/experiment.json";

info = getExperimentInfo(experiment_json; replace_info=replace_info_spatial);

path_model = joinpath("/Net/Groups/BGI/work_5/scratch/lalonso/checkpoint_epoch_208.jld2")
model_props = JLD2.load(path_model)
tbl_params = model_props["parameter_table"]

forcing = getForcing(info);
ds = open_dataset("/Net/Groups/BGI/work_4/scratch/lalonso/GlobalForcingSet.zarr");

run_helpers = prepTEM(forcing, info);