using Revise
using Sindbad

toggleStackTraceNT()
experiment_json = "exp_loadData/settings_loadData/experiment.json"
begin_year = "1979"
end_year = "2017"
path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
path_observation = path_input
forcing_config = "forcing_erai.json"
optimize_it = false
path_output = nothing
domain = "DE-Hai"

replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.model_output.path" => path_output,
    "optimization.observations.default_observation.data_path" => path_observation);

run_output = runExperiment(experiment_json; replace_info=replace_info);

# run with saved jld2 file
experiment_jld2 = "exp_loadData/info.jld2"
replace_info["path_output"] = "jld2"
run_output = runExperiment(experiment_jld2); #this one will only work if the replace fields are not passed because of isses with merging namedtuple and dict, and/or conversion of named tuple to dictionary

# one can load info directly from file and run the experiment by skipping the get configuration by continuing with
info = Sindbad.load("info.jld2")["info"];
forcing = getForcing(info)


