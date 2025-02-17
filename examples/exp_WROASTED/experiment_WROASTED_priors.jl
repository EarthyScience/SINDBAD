using Revise
using SindbadExperiment

# TODO add to SindbadOptimization
using Distributions, PDMats, DistributionFits, Turing, MCMCChains

using BenchmarkTools
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "1979"
end_year = "2017"

path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
forcing_config = "forcing_erai.json"
path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing
# t
domain = "DE-Hai"
parallelization_lib = "threads"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => true,
    "experiment.flags.debug_model" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "forcing.default_forcing.data_path" => path_input,
    "experiment.model_output.path" => path_output,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

#Sindbad.eval(:(error_catcher = []))    
run_helpers = prepTEM(forcing, info);

@time runTEM!(info.models.forward, run_helpers.space_forcing, run_helpers.space_spinup_forcing, run_helpers.loc_forcing_t, run_helpers.space_output, run_helpers.space_land, run_helpers.tem_info)

observations = getObservation(info, forcing.helpers);
obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

@time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info);
opt_params = out_opti.params;


"""
getObsAndUnc(observations::NamedTuple, optim::NamedTuple; removeNaN=true)

extract a matrix with columns:

  - observations
  - observation uncertainties (stdev)
"""
function getObsAndUnc(obs::NamedTuple, optim::NamedTuple; removeNaN=true)
    cost_options = optim.cost_options
    optim_vars = optim.variables.optim
    res = map(cost_options) do var_row
        obsV = var_row.variable
        y = getproperty(obs_array, obsV)
        yσ = getproperty(obs_array, Symbol(string(obsV) * "_σ"))
        [vec(y) vec(yσ)]
    end
    resM = vcat(res...)
    return resM, isfinite.(resM[:, 1])
    #TODO do with fewer allocations
end

"""
    getPredAndObsVector(observations::NamedTuple, model_output, optim::NamedTuple)

extract a matrix with columns:

  - observations
  - observation uncertainties (stdev)
  - model prediction
"""
function getPredAndObsVector(observations::NamedTuple,
    model_output,
    optim::NamedTuple;
    removeNaN=true)
    cost_options = optim.cost_options
    optim_vars = optim.variables.optim
    res = map(cost_options) do var_row
        obsV = var_row.variable
        mod_variable = getfield(optim_vars, obsV)
        #TODO care for equal size
        (y, yσ, ŷ) = getData(model_output, observations, obsV, mod_variable)
        [vec(y) vec(yσ) vec(ŷ)]
    end
    resM = vcat(res...)
    return resM, isfinite.(resM[:, 1])
    #TODO do with fewer allocations
end

@time out_opti = runExperimentOpti(experiment_json; replace_info=replace_info);
opt_params = out_opti.params;
pred_obs, is_finite_obs = getObsAndUnc(obs_array, info.optimization)

develop_f =
    () -> begin
        #code run from @infiltrate in optimizeTEM
        # d = shifloNormal(2,5)
        # using StatsPlots
        # plot(d)

        tbl_params = getParameters(tem.models.forward, optim.model_parameter_default,
            optim.model_parameters_to_optimize,
            info.helpers.numbers.num_type, info.helpers.dates.temporal_resolution)
        # get the default and bounds
        default_values = tem.helpers.numbers.num_type.(tbl_params.default)
        lower_bounds = tem.helpers.numbers.num_type.(tbl_params.lower)
        upper_bounds = tem.helpers.numbers.num_type.(tbl_params.upper)

        run_helpers = prepTEM(forcing, info)

        priors_opt = shifloNormal.(lower_bounds, upper_bounds)
        x = default_values
        pred_obs, is_finite_obs = getObsAndUnc(obs_array, optim)

        #TODO get y and sigmay beforehand and construct MvNormal

        m_sesamfit = Turing.@model function sesamfit(obs_array, ::Type{T}=Float64) where {T}
            #assumptions/priors
            local popt = Vector{T}(undef, length(priors_opt))
            #popt_unscaled = Vector{T}(undef, length(popt_dist))
            #parallelization_lib =  Vector{T}(undef, length(srl2))
            #local (i,r) = first(enumerate(priors_opt))
            for (i, r) ∈ enumerate(priors_opt)
                popt[i] ~ r
            end
            local is_priorcontext = DynamicPPL.leafcontext(__context__) == Turing.PriorContext()
            #
            # tbl_params.optim .= popt  # TODO replace mutation

            updated_models = updateModelParameters(tbl_params, tem.models.forward, popt)
            # TODO run model with updated parameters

            @time runTEM!(updated_models,
                run_helpers.space_forcing,
                run_helpers.space_spinup_forcing,
                run_helpers.loc_forcing_t,
                run_helpers.space_output,
                run_helpers.space_land,
                run_helpers.tem_info)
        
            # get predictions and observations
            model_output = (; Pair.(output_variables, output)...)
            pred_obs, is_finite_obs = getPredAndObsVector(observations, model_output, optim)

            dObs = MvNormal(pred_obs[is_finite_obs, 1], PDiagMat(pred_obs[is_finite_obs, 2]))
            # pdf(dObs, pred_obs[is_finite_obs,3])
            return pred_obs[is_finite_obs, 3] ~ dObs
        end

        n_burnin = 0
        n_sample = 10
        #Turing.sample(sesamfit, MCMC(n_burnin, 0.65, init_ϵ = 1e-2),  n_sample, init_params=popt0)
        Turing.sample(m_sesamfit, MH(), n_sample)
    end
