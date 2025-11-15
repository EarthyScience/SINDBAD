# ENV["JULIA_NUM_PRECOMPILE_TASKS"] = "1"
using Distributed
using SlurmClusterManager # pkg> add https://github.com/lazarusA/SlurmClusterManager.jl.git#la/asynclaunch
addprocs(SlurmManager())

using Sindbad
using SindbadUtils
using SindbadTEM
using SindbadData
using SindbadSetup
using SindbadML.JLD2

@everywhere begin
    import Pkg
    Pkg.activate(@__DIR__)
    using Sindbad
    using SindbadUtils
    using SindbadTEM
    using SindbadData
    using SindbadSetup
    using SindbadML.JLD2
end

@everywhere println("Worker $(myid()): Number of Threads = ", Threads.nthreads())

include("fire_models.jl");

experiment_output = "PFT_025"
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

path_model = joinpath("/Net/Groups/BGI/work_5/scratch/lalonso/checkpoint_epoch_208.jld2") #! update path!
model_props = JLD2.load(path_model)
tbl_params = model_props["parameter_table"]

forcing = getForcing(info);
# ds = open_dataset("/Net/Groups/BGI/work_4/scratch/lalonso/GlobalForcingSet.zarr");
run_helpers = prepTEM(forcing, info);

tuple_models = getTupleFromLongTuple(info.models.forward);

# ? newly generated parameters with PFTs only as covariates
ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_PFT_new_0d25.zarr"

in_cube_params = Cube(ps_path)
in_cube_ps = permutedims(in_cube_params, (2,3,1))
in_cube_ps = readcubedata(in_cube_ps)

yax_max_cache = info.experiment.exe_rules.yax_max_cache

outcubes = SindbadTEM.runTEMYaxParameters(
    tuple_models,
    forcing,
    in_cube_ps,
    tbl_params,
    info);