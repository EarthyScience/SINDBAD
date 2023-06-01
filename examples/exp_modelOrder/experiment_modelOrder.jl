using Revise
using Sindbad
experiment_json = "exp_modelOrder/settings_modelOrder/experiment.json"

# do the full experiment at once based purely on json
run_output = runExperiment(experiment_json);

