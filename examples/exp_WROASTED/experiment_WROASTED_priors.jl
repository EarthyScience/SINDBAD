using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad

# TODO add to OptimizeSindbad
using Distributions, PDMats, DistributionFits, Turing, MCMCChains
# using Cthulhu
using BenchmarkTools
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"

path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
# path_input = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
path_input = "../data/BE-Vie.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
# path_input = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
# path_input = "/Net/Groups/BGI/scratch/skoirala/sindbad.jl/examples/data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
path_observation = path_input
optimize_it = true
optimize_it = false
path_output = nothing
# t
domain = "DE-Hai"
pl = "threads"
replace_info = Dict("model_run.time.start_date" => sYear * "-01-01",
    "experiment.configuration_files.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "model_run.time.end_date" => eYear * "-12-31",
    "model_run.flags.run_optimization" => optimize_it,
    "model_run.flags.run_forward_and_cost" => true,
    "model_run.flags.spinup.save_spinup" => false,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.run_spinup" => true,
    "model_run.flags.debug_model" => false,
    "model_run.flags.spinup.do_spinup" => true,
    "forcing.default_forcing.data_path" => path_input,
    "model_run.output.path" => path_output,
    "model_run.mapping.parallelization" => pl,
    "optimization.constraints.default_constraint.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

forcing = getForcing(info);

#Sindbad.eval(:(error_catcher = []))    
forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
    prepRunEcosystem(forcing, info);
@time runEcosystem!(output_array,
    info.tem.models.forward,
    forcing_nt_array,
    tem_with_vals,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)

observations = getObservation(info, forcing.helpers);
obs_array = getKeyedArrayWithNames(observations);

@time out_params = runExperimentOpti(experiment_json; replace_info=replace_info);


"""
getObsAndUnc(observations::NamedTuple, optim::NamedTuple; removeNaN=true)

extract a matrix with columns:

  - observations
  - observation uncertainties (stdev)
"""
function getObsAndUnc(obs::NamedTuple, optim::NamedTuple; removeNaN=true)
    cost_options = optim.cost_options
    optimVars = optim.variables.optim
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
    optimVars = optim.variables.optim
    res = map(cost_options) do var_row
        obsV = var_row.variable
        mod_variable = getfield(optimVars, obsV)
        #TODO care for equal size
        (y, yσ, ŷ) = getData(model_output, observations, obsV, mod_variable)
        [vec(y) vec(yσ) vec(ŷ)]
    end
    resM = vcat(res...)
    return resM, isfinite.(resM[:, 1])
    #TODO do with fewer allocations
end

out_params = runExperimentOpti(experiment_json; replace_info=replace_info);
pred_obs, is_finite_obs = getObsAndUnc(obs_array, info.optim)

develop_f =
    () -> begin
        #tbl = getParameters(info.tem.models.forward, info.optim.optimized_parameters);
        #code run from @infiltrate in optimizeModel
        # d = shifloNormal(2,5)
        # using StatsPlots
        # plot(d)

        tbl_params = Sindbad.getParameters(tem.models.forward, optim.default_parameter,
            optim.optimized_parameters)
        # get the default and bounds
        default_values = tem.helpers.numbers.sNT.(tbl_params.default)
        lower_bounds = tem.helpers.numbers.sNT.(tbl_params.lower)
        upper_bounds = tem.helpers.numbers.sNT.(tbl_params.upper)

        forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one =
            prepRunEcosystem(tem.models.forward, forcing, tem)
        priors_opt = shifloNormal.(lower_bounds, upper_bounds)
        x = default_values
        pred_obs, is_finite_obs = getObsAndUnc(obs_array, optim)

        #TODO get y and sigmay beforehand and construct MvNormal

        #priors_opt, dObs, is_finite_obs
        #output, tem.models.forward, forcing, tem, forcing_nt_array, output_array, loc_space_maps, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, tem_with_vals, f_one, loc_forcing, loc_output
        #output_variables, optim
        m_sesamfit = Turing.@model function sesamfit(obs_array, ::Type{T}=Float64) where {T}
            #assumptions/priors
            local popt = Vector{T}(undef, length(priors_opt))
            #popt_unscaled = Vector{T}(undef, length(popt_dist))
            #pl =  Vector{T}(undef, length(srl2))
            #local (i,r) = first(enumerate(priors_opt))
            for (i, r) ∈ enumerate(priors_opt)
                popt[i] ~ r
            end
            local is_priorcontext = DynamicPPL.leafcontext(__context__) == Turing.PriorContext()
            #
            # tbl_params.optim .= popt  # TODO replace mutation

            newApproaches = updateModelParameters(tbl_params, tem.models.forward, popt)
            # TODO run model with updated parameters
            runEcosystem!(output_array,
                output.land_init,
                newApproaches,
                forcing,
                tem_with_vals,
                loc_space_inds,
                loc_forcings,
                loc_outputs,
                land_init_space,
                f_one)

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
