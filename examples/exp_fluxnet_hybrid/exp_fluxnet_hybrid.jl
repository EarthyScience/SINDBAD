using SindbadData
using SindbadData: DimensionalData, AxisKeys, YAXArrays
using SindbadTEM
using SindbadML
using ProgressMeter

experiment_json = "../exp_fluxnet_hybrid/settings_fluxnet_hybrid/experiment.json"
# for remote node
replace_info = Dict()
if Sys.islinux()
    replace_info = Dict(
        "forcing.default_forcing.data_path" => "/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr",
        "optimization.observations.default_observation.data_path" =>"/Net/Groups/BGI/work_4/scratch/lalonso/FLUXNET_v2023_12_1D.zarr"
        );
end

info = getExperimentInfo(experiment_json; replace_info=replace_info);

tbl_params = getParameters(info.models.forward, info.optimization.model_parameter_default, info.optimization.model_parameters_to_optimize, info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution);

forcing = getForcing(info);
observations = getObservation(info, forcing.helpers);
selected_models = info.models.forward
param_to_index = getParameterIndices(selected_models, tbl_params);
run_helpers = prepTEM(selected_models, forcing, observations, info);