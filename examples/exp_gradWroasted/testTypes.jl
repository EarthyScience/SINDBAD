using Revise
using ForwardDiff
using SindbadData
using SindbadTEM
using SindbadMetrics
using SindbadExperiment
toggleStackTraceNT()

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
replace_info = Dict(
    "experiment.flags.debug_model" => false,
"experiment.exe_rules.model_number_type" => "Float32")

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optim.cost_options);

run_helpers = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

# @time spinupTEM(
#     info.tem.models.forward,
#     run_helpers.loc_spinup_forcings[1],
#     run_helpers.forcing_one_timestep,
#     run_helpers.land_init_space[1],
#     run_helpers.tem_with_types.helpers,
#     run_helpers.tem_with_types.models,
#     run_helpers.tem_with_types.spinup);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);


p_vec = tbl_params.default * 1.0;

p_vec = ForwardDiff.Dual.(tbl_params.default);

@time mods = updateModelParameters(info.tem.models.forward, p_vec, info.optim.param_model_id_val);

run_helpers_d = prepTEM(mods, forcing, info);

# @time SindbadTEM.runTimeStep2(mods, run_helpers_d.loc_forcings[1], run_helpers_d.forcing_one_timestep, run_helpers_d.loc_outputs[1], run_helpers_d.land_init_space[1], run_helpers_d.tem_with_types.helpers.vals.forc_types, run_helpers_d.tem_with_types.helpers.model_helpers, run_helpers_d.tem_with_types.helpers.vals.output_vars, 1)

@time runTEM!(mods,
    run_helpers_d.loc_forcings,
    run_helpers_d.loc_spinup_forcings,
    run_helpers_d.forcing_one_timestep,
    run_helpers_d.loc_outputs,
    run_helpers_d.land_init_space,
    run_helpers_d.tem_with_types)

    
@time coreTEM!(mods,
    run_helpers_d.loc_forcings[1],
    run_helpers_d.loc_spinup_forcings[1],
    run_helpers_d.forcing_one_timestep,
    run_helpers_d.loc_outputs[1],
    run_helpers_d.land_init_space[1],
    run_helpers_d.tem_with_types.helpers,
    run_helpers_d.tem_with_types.models,
    run_helpers_d.tem_with_types.spinup,
    run_helpers_d.tem_with_types.helpers.run.spinup.spinup_TEM
    )


