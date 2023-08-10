using Revise
using ForwardDiff

using SindbadOptimization

toggleStackTraceNT()

experiment_json = "../exp_gradWroasted/settings_gradWroasted/experiment.json"
info = getExperimentInfo(experiment_json);

forcing = getForcing(info);

# Sindbad.eval(:(error_catcher = []));
land_init = createLandInit(info.pools, info.tem.helpers, info.tem.models);
op = setupOutput(info, forcing.helpers);
observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArray(observations);


forcing_nt_array, loc_forcings, forcing_one_timestep, output_array, loc_outputs, land_init_space, loc_space_inds, loc_space_maps, loc_space_names, tem_with_vals = prepTEM(forcing, info);


@time runTEM!(info.tem.models.forward,
    forcing_nt_array,
    loc_forcings,
    forcing_one_timestep,
    output_array,
    loc_outputs,
    land_init_space,
    loc_space_inds,
    tem_with_vals)

# @time out_params = runExperimentOpti(experiment_json);  
tbl_params = Sindbad.getParameters(info.tem.models.forward,
    info.optim.model_parameter_default,
    info.optim.model_parameters_to_optimize);


rand_m = rand(info.tem.helpers.numbers.num_type);
# op = setupOutput(info, forcing.helpers);

mods = info.tem.models.forward;

dualDefs = ForwardDiff.Dual{info.tem.helpers.numbers.num_type}.(tbl_params.default);
newmods = updateModelParametersType(tbl_params, mods, dualDefs);

function l1(p)
    return getLoss(p,
        mods,
        forcing_nt_array,
        output_array,
        obs_array,
        tbl_params,
        tem_with_vals,
        info.optim.cost_options,
        info.optim.multi_constraint_method,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        forcing_one_timestep)
end
for _ in 1:10
    @show l1(rand_m .* tbl_params.default)
end
# CHUNK_SIZE = 20
p_vec = tbl_params.default;
CHUNK_SIZE = 10#length(p_vec)
cfg = ForwardDiff.GradientConfig(l1, p_vec, ForwardDiff.Chunk{CHUNK_SIZE}());

output = setupOutput(info, forcing.helpers);
output_array = [Array{ForwardDiff.Dual{ForwardDiff.Tag{typeof(l1),info.tem.helpers.numbers.num_type},info.tem.helpers.numbers.num_type,CHUNK_SIZE}}(undef, size(od)) for od in output.data];


@time grad = ForwardDiff.gradient(l1, p_vec, cfg)
# @profview grad = ForwardDiff.gradient(l1, p_vec, cfg)
