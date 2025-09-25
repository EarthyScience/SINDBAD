using Revise
using SindbadML
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

path_covariates = "$(getSindbadDataDepot())/CovariatesFLUXNET_3.zarr"

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

hybrid_helpers = prepHybrid(forcing, observations, info, info.hybrid.ml_training.method);

trainML(hybrid_helpers, info.hybrid.ml_training.method)




