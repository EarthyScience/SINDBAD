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

@time spinupTEM(
    info.tem.models.forward,
    run_helpers.loc_spinup_forcings[1],
    run_helpers.forcing_one_timestep,
    run_helpers.land_init_space[1],
    run_helpers.tem_with_types.helpers,
    run_helpers.tem_with_types.models,
    run_helpers.tem_with_types.spinup);

tbl_params = getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize,
    info.tem.helpers.numbers.sNT);

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

mods = info.tem.models.forward;
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


p_vec = tbl_params.default;

l1(p_vec)

CHUNK_SIZE = length(p_vec)
CHUNK_SIZE = 10

cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

dualDefs = ForwardDiff.Dual.(tbl_params.default);
dualDefs = ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}.(tbl_params.default);
@time mods = updateModelParameters(info.tem.models.forward, dualDefs, info.optim.param_model_id_val);

run_helpers_d = prepTEM(mods, forcing, info);

@time SindbadTEM.runTimeStep2(mods, run_helpers_d.loc_forcings[1], run_helpers_d.forcing_one_timestep, run_helpers_d.loc_outputs[1], run_helpers_d.land_init_space[1], run_helpers_d.tem_with_types.helpers.vals.forc_types, run_helpers_d.tem_with_types.helpers.model_helpers, run_helpers_d.tem_with_types.helpers.vals.output_vars, 1)
# @time lw_timeseries_prep = runTEM(info.tem.models.forward, run_helpers.loc_forcings[1], run_helpers.loc_spinup_forcings[1], run_helpers.forcing_one_timestep, run_helpers.land_one, run_helpers.tem_with_types);

@time runTEM!(mods,
    run_helpers_d.loc_forcings,
    run_helpers_d.loc_spinup_forcings,
    run_helpers_d.forcing_one_timestep,
    run_helpers_d.loc_outputs,
    run_helpers_d.land_init_space,
    run_helpers_d.tem_with_types)

    @code_warntype coreTEM!(mods,
    run_helpers_d.loc_forcings[1],
    run_helpers_d.loc_spinup_forcings[1],
    run_helpers_d.forcing_one_timestep,
    run_helpers_d.loc_outputs[1],
    run_helpers_d.land_init_space[1],
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

    @code_warntype coreTEM!(mods,
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
    # selected_models,
    # loc_forcing,
    # loc_spinup_forcing,
    # forcing_one_timestep,
    # loc_output,
    # land_init,
    # tem_helpers,
    # tem_models,
    # tem_spinup,
    # ::DoSpinupTEM
@time spinupTEM(
    mods,
    run_helpers_d.loc_spinup_forcings[1],
    run_helpers_d.forcing_one_timestep,
    run_helpers_d.land_init_space[1],
    run_helpers_d.tem_with_types.helpers,
    run_helpers_d.tem_with_types.models,
    run_helpers_d.tem_with_types.spinup);

# op = prepTEMOut(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_types.helpers.numbers.num_type},tem_with_types.helpers.numbers.num_type,10}}(undef, size(od)) for od in run_helpers.output_array];
# op = (; op..., data=op_dat);

@time grad = ForwardDiff.gradient(l1, dualDefs)



# op = prepTEMOut(info, forcing.helpers);
# op_dat = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),tem_with_types.helpers.numbers.num_type},tem_with_types.helpers.numbers.num_type,10}}(undef, size(od)) for od in run_helpers.output_array];
# op = (; op..., data=op_dat);

@time grad = ForwardDiff.gradient(l1, p_vec)


# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)

# @time grad = ForwardDiff.gradient(l1, p_vec, cfg)



