using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()
using FileIO

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
runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);

##test timing
for tt = 1:5
    @time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
end

# using output of opti to update parameters and do a forward run
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.optimized_parameters);
tblParams.optim .= outparams; # update the parameters with pVector

newApproaches = updateParameters(tblParams, info.tem.models.forward);
runEcosystem!(output.data, newApproaches, forc, info.tem);

model_data_d = (; Pair.(output.variables, outcubes)...);
model_data_o = (; Pair.(output.variables, output.data)...);

## some plotting

using CairoMakie, AlgebraOfGraphics, DataFrames, Dates

spacesize = (2, 2)

sp_it = Iterators.product(Base.OneTo.(spacesize)...)
for sel_ind in sp_it
    for obsvar in info.optim.variables.obs
        modelvar = getfield(info.optim.variables.optim, obsvar)[2]
        obsdat = Array(getfield(obs, obsvar)[sel_ind..., :])
        moddat_o = Array(getfield(model_data_o, modelvar)[:, sel_ind...])
        moddat_d = Array(getfield(model_data_d, modelvar)[:, sel_ind...])
        df = DataFrame(time = info.tem.helpers.dates.vector, obs = obsdat, def=moddat_d, opt=moddat_o);
        # @show df
        keysd = (:obs, :def, :opt)
        if !all(isnan, obsdat)
            figin = nothing
            with_theme(theme_ggplot2(), resolution = (1200,400)) do 
                figin = Figure()
                ax = Axis(figin[1,1], ylabel=string(obsvar), xlabel = "time")
                for ind in eachindex(keysd)
                    lines!(ax, df[!, keysd[ind]], label=string(keysd[ind]))
                end
            end
            axislegend()
            sel_str = join(sel_ind, "-")
            filename = "$(obsvar)_$(sel_str).png"
            @show filename
            save("$(obsvar)_$(sel_str).png", figin)
        end
    end
end
