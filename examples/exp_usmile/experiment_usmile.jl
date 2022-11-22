using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()

experiment_json = "../exp_usmile/settings_lue/experiment.json"
# experiment_json = "../exp_usmile/settings_w/experiment.json"
# experiment_json = "../exp_usmile/settings_cw/experiment.json"


outcubes = runExperimentForward(experiment_json);  

outparams = runExperimentOpti(experiment_json);  


## inner interfaces; get intermediate objects

info = getExperimentInfo(experiment_json);
info, forcing, output, observations = prepExperimentOpti(experiment_json);

# change disk array to memory keyed arrays
forc = getKeyedArrayFromYaxArray(forcing);
obs = getKeyedArrayFromYaxArray(observations);

## run the main ecosystem loop
runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, info.tem.helpers.run.parallelization);

##test timing
for tt = 1:5
    @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, info.tem.helpers.run.parallelization);
end

# using output of opti to update parameters and do a forward run
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.optimized_parameters);
tblParams.optim .= outparams; # update the parameters with pVector

newApproaches = updateParameters(tblParams, info.tem.models.forward);
runEcosystem!(output.data, newApproaches, forc, info.tem, info.tem.helpers.run.parallelization);
model_data = (; Pair.(output.variables, output.data)...);

## some plotting

using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

spacesize = (2, 2)
sel_str = join(spacesize, "x")
sel_str = join(sel_ind, "x")

sp_it = Iterators.product(Base.OneTo.(spacesize)...)
for sel_ind in sp_it
    for obsvar in info.optim.variables.obs
        modelvar = getfield(info.optim.variables.optim, obsvar)[2]
        obsdat = Array(getfield(obs, obsvar)[sel_ind..., :])
        moddat = Array(getfield(model_data, modelvar)[:, sel_ind...])
        if !all(isnan, obsdat)
            # fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
                    # draw(obsdat)
                    # draw(moddat)
                # end
            sel_str = join(sel_ind, ",")
            filename = "$(obsvar)_$(sel_str).png"
            @show size(obsdat), size(moddat), "plotting", filename
        end
            # save("$(obsvar)_$(sel_str).png", fig)
    end
end

# for site in 1:16
#     df = DataFrame(time = 1:730, gpp = plotdat[end-1][:,site], nee = plotdat[end][:,site], soilw1 = plotdat[2][1,:,site]);

#     for var = (:gpp, :nee, :soilw1)
#         d = data(df)*mapping(:time, var)*visual(Lines, linewidth=0.5);

#         fig = with_theme(theme_ggplot2(), resolution = (1200,400)) do
#             draw(d)
#         end
#         save("testfig_$(var)_$(site).png", fig)
#     end
# end