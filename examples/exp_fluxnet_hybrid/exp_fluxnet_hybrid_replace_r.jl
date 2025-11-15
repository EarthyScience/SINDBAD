using Revise
using SindbadML
using SindbadTEM
using SindbadUtils
using SindbadSetup
using SindbadData
using SindbadML.JLD2
using SindbadML.Random
using SindbadML.Flux
using ProgressMeter

# TODO: update these in replace_info!
# TODO: proper attribution of trainML file!
# load folds # $nfold $nlayer $neuron $batchsize
_nfold = 5 # Base.parse(Int, ARGS[1]) # 5
nlayers = 3 # Base.parse(Int, ARGS[2]) # 3
n_neurons = 32 # Base.parse(Int, ARGS[3]) # 32
batch_size = 32 # Base.parse(Int, ARGS[4]) # 32
id_fold = 1 #  Base.parse(Int, ARGS[5]) # 1


path_experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment_hybrid.json"
# path_input = "$(getSindbadDataDepot())/FLUXNET_v2023_12_1D.zarr"
path_input = "/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr"
path_observation = path_input

# path_covariates = "$(getSindbadDataDepot())/CovariatesFLUXNET_3.zarr"

replace_info = Dict(
    "forcing.default_forcing.data_path" => path_input,
    "optimization.observations.default_observation.data_path" => path_observation,
    "optimization.optimization_cost_threaded" => false,
    "hybrid.ml_training.options.batch_size" => batch_size,
    "hybrid.ml_training.which_fold" => _nfold,
    # "hybrid.ml_training.fold_path" => "blablabla",
    "hybrid.ml_model.options.n_layers" => nlayers,
    "hybrid.ml_model.options.n_neurons" => n_neurons,
)

info = getExperimentInfo(path_experiment_json; replace_info=replace_info);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
sites_forcing = forcing.data[1].site;

# disturbance years
# get disturbance years from forcing helpers
# apply getSequence to each site
# ds = open_dataset(path_input)
# disturbances_per_site = Pair.(ds.properties["SITE_ID"], ds.properties["last_disturbance_on"])
# allSequences = getSequence.(ds.properties["last_disturbance_on"], Ref(info.helpers.dates));

hybrid_helpers = prepHybrid(forcing, observations, info, info.hybrid.ml_training.method);
selected_models = info.models.forward;
run_helpers = hybrid_helpers.run_helpers;

space_forcing = run_helpers.space_forcing;
space_observations = run_helpers.space_observation;
space_output = run_helpers.space_output;
space_spinup_forcing = run_helpers.space_spinup_forcing;
space_spinup_sequence = run_helpers.space_spinup_sequence;
space_ind = run_helpers.space_ind;
land_init = run_helpers.loc_land;
loc_forcing_t = run_helpers.loc_forcing_t;

space_cost_options = [prepCostOptions(loc_obs, info.optimization.cost_options) for loc_obs in space_observations];
constraint_method = info.optimization.run_options.multi_constraint_method;

tem_info = run_helpers.tem_info;
## do example site
##

site_example_1 = space_ind[7][1];
@time SindbadTEM.coreTEM!(selected_models, space_forcing[site_example_1], space_spinup_forcing[site_example_1],
    space_spinup_sequence[site_example_1],
    loc_forcing_t, space_output[site_example_1], land_init, tem_info)

trainML(hybrid_helpers, info.hybrid.ml_training.method)


# ds = open_dataset(path_input)
# d_arr = replace(ds.properties["last_disturbance_on"], "undisturbed" => "9999-01-01")
# disturbance_yax = YAXArray((ds.site, ), year.(Date.(d_arr)))
# ds2 = Dataset(disturbance_year = disturbance_yax)
# savedataset(ds2, path=path_input, backend=:zarr, append=true)

