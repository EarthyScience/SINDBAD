using SindbadData
using SindbadTEM
using YAXArrays
#using HybridSindbad
using SindbadVisuals
using ForwardDiff
using PreallocationTools
using GLMakie

toggleStackTraceNT()
# include("gen_obs.jl")
# obs_synt = out_synt();

experiment_json = "../exp_repacking/settings_repacking/experiment.json"
#info = getConfiguration(experiment_json);
#info = setupInfo(info);

info = getExperimentInfo(experiment_json);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);

selected_models = info.tem.models.forward;
#models_arr_new = [m for m in models]
new_params = tbl_params.default

param_to_index = param_indices(selected_models, tbl_params)

#CSV.write("table_params.csv", tbl_params)

old_models = updateModelParametersType(tbl_params, selected_models, new_params);
#@time updateModelParametersType(param_to_index, selected_models, new_params);
@time new_models = updateModelParametersType(param_to_index, selected_models, new_params);

for i in eachindex(new_models)
    true_false = old_models[i] == new_models[i]
    if !true_false
        println(i)
    end
end

for i in eachindex(new_models)
    true_false = old_models[i] == new_models[i]
    if true_false
        println(true_false)
    end
end