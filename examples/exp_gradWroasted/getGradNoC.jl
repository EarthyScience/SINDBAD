using Revise
using ForwardDiff
using SindbadData
using SindbadTEM
using SindbadMetrics
using SindbadExperiment
toggleStackTraceNT()

experiment_json = "../exp_gradWroasted/settings_gradNoC/experiment.json"
replace_info = Dict(
    "experiment.flags.debug_model" => false,
"experiment.exe_rules.model_number_type" => "Float32")

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow
cost_options = prepCostOptions(obs_array, info.optim.cost_options);

function g_loss(x,
    mods,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    tem_with_types,
    observations,
    param_model_id_val,
    p_type,
    cost_options,
    multi_constraint_method)
    l = getLoss(x,
        mods,
        loc_forcings,
        loc_spinup_forcings,
        forcing_one_timestep,
        output_array,
        loc_outputs,
        land_init_space,
        tem_with_types,
        observations,
        param_model_id_val,
        p_type,
        cost_options,
        multi_constraint_method)
    return l
end

# mods = info.tem.models.forward;
function l1(p)
    return g_loss(p,
        mods,
        run_helpers.loc_forcings,
        run_helpers.loc_spinup_forcings,
        run_helpers.forcing_one_timestep,
        run_helpers.output_array,
        run_helpers.loc_outputs,
        run_helpers.land_init_space,
        run_helpers.tem_with_types,
        obs_array,
        info.optim.param_model_id_val,
        typeof(tbl_params.default),
        cost_options,
        info.optim.multi_constraint_method)
end




tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);


CHUNK_SIZE = 10
    # p_vec = tbl_params.default;
p_vec = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
@time mods = updateModelParameters(info.tem.models.forward, p_vec, info.optim.param_model_id_val);


run_helpers = prepTEM(mods, forcing, info);

@time runTEM!(mods,
    run_helpers.loc_forcings,
    run_helpers.loc_spinup_forcings,
    run_helpers.forcing_one_timestep,
    run_helpers.loc_outputs,
    run_helpers.land_init_space,
    run_helpers.tem_with_types)

@time l1(p_vec)

# CHUNK_SIZE = length(p_vec)
# CHUNK_SIZE = 10

cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

# dualDefs = ForwardDiff.Dual.(tbl_params.default);
# dualDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
# @time mods = updateModelParameters(info.tem.models.forward, dualDefs, info.optim.param_model_id_val);
# op = (; op..., data=op_dat);

# @time grad = ForwardDiff.gradient(l1, tbl_params.default)

# ::Vector{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}


@time grad = ForwardDiff.gradient(l1, p_vec)

# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)



