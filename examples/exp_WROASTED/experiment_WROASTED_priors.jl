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

inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
inpath = "../data/BE-Vie.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
inpath = "../data/DE-2.1979.2017.daily.nc"
forcingConfig = "forcing_DE-2.json"
# inpath = "/Net/Groups/BGI/scratch/skoirala/sindbad.jl/examples/data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
obspath = inpath
optimize_it = true
optimize_it = false
outpath = nothing
# t
domain = "DE-Hai"
pl = "threads"
replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.debugit" => false,
    "modelRun.flags.runSpinup" => true,
    "modelRun.flags.debugit" => false,
    "spinup.flags.doSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info


forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

#Sindbad.eval(:(error_catcher = []))    
loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time outcubes = runExperimentOpti(experiment_json; replace_info=replace_info);  


observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);



"""
getObsAndUnc(observations::NamedTuple, optim::NamedTuple; removeNaN=true)

extract a matrix with columns:
- observations
- observation uncertainties (stdev)
"""
function getObsAndUnc(obs::NamedTuple, optim::NamedTuple; removeNaN=true)
    cost_options = optim.costOptions
    optimVars = optim.variables.optim
    res = map(cost_options) do var_row
        obsV = var_row.variable
        y = getproperty(obs, obsV)
        yσ = getproperty(obs, Symbol(string(obsV) * "_σ"))
        [vec(y) vec(yσ)]
    end
    resM = vcat(res...)
    resM, isfinite.(resM[:,1])
    #TODO do with fewer allocations
end

"""
    getPredAndObsVector(observations::NamedTuple, model_output, optim::NamedTuple)

extract a matrix with columns:
- observations
- observation uncertainties (stdev)
- model prediction
"""
function getPredAndObsVector(observations::NamedTuple, model_output, optim::NamedTuple; removeNaN=true)
    cost_options = optim.costOptions
    optimVars = optim.variables.optim
    res = map(cost_options) do var_row
        obsV = var_row.variable
        mod_variable = getfield(optimVars, obsV)
        #TODO care for equal size
        (y, yσ, ŷ) = getDataArray(model_output, observations, obsV, mod_variable)
        [vec(y) vec(yσ) vec(ŷ)]
    end
    resM = vcat(res...)
    resM, isfinite.(resM[:,1])
    #TODO do with fewer allocations
end



outcubes = runExperimentOpti(experiment_json; replace_info=replace_info);  
pred_obs, is_finite_obs = getObsAndUnc(obs, info.optim)


develop_f = () -> begin
    #tbl = getParameters(info.tem.models.forward, info.optim.optimized_parameters);
    #code run from @infiltrate in optimizeModelArray
    # d = shifloNormal(2,5)
    # using StatsPlots
    # plot(d)

    tblParams = Sindbad.getParameters(tem.models.forward, optim.optimized_parameters)
    # get the defaults and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
    lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)
    loc_space_maps, land_init_space, f_one, loc_forcing, loc_output  = prepRunEcosystem(output, tem.models.forward, forcing, tem);

    priors_opt = shifloNormal.(lower_bounds,upper_bounds)
    x = default_values
    pred_obs, is_finite_obs = getObsAndUnc(obs, optim)

    #TODO get y and sigmay beforehand and construct MvNormal

    #priors_opt, dObs, is_finite_obs
    #output, tem.models.forward, forcing, tem, loc_space_maps, land_init_space, f_one, loc_forcing, loc_output
    #output_variables, optim
    m_sesamfit = Turing.@model function sesamfit(obs, ::Type{T} = Float64) where {T}
        #assumptions/priors
        local popt = Vector{T}(undef, length(priors_opt))
        #popt_unscaled = Vector{T}(undef, length(popt_dist))
        #pl =  Vector{T}(undef, length(srl2))
        #local (i,r) = first(enumerate(priors_opt))
        for (i,r) = enumerate(priors_opt)
            popt[i] ~ r
        end
        local is_priorcontext = DynamicPPL.leafcontext(__context__) == Turing.PriorContext()
        #
        tblParams.optim .= popt  # TODO replace mutation
        
        newApproaches = updateModelParameters(tblParams, tem.models.forward, popt)
        # TODO run model with updated parameters
        runEcosystem!(output.data, output.land_init, newApproaches, forcing, tem, loc_space_maps, land_init_space, f_one)

        # get predictions and observations
        model_output = (; Pair.(output_variables, output)...)
        pred_obs, is_finite_obs = getPredAndObsVector(observations, model_output, optim)

        dObs = MvNormal(pred_obs[is_finite_obs,1], PDiagMat(pred_obs[is_finite_obs,2]))
        # pdf(dObs, pred_obs[is_finite_obs,3])
        pred_obs[is_finite_obs,3] ~ dObs

    end

    n_burnin = 0; n_sample = 10
    #Turing.sample(sesamfit, MCMC(n_burnin, 0.65, init_ϵ = 1e-2),  n_sample, init_params=popt0)
    Turing.sample(m_sesamfit, MH(),  n_sample)



end
