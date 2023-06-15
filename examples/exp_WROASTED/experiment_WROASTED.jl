using Revise
using Sindbad
using ForwardSindbad
using OptimizeSindbad
noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "2000"
eYear = "2017"

# inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
# forcingConfig = "forcing_erai.json"
# inpath = "../data/DE-2.1979.2017.daily.nc"
# forcingConfig = "forcing_DE-2.json"
inpath = "../data/BE-Vie.1979.2017.daily.nc"
forcingConfig = "forcing_erai.json"
obspath = inpath
optimize_it = true
# optimize_it = false
outpath = nothing

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
    "modelRun.flags.catchErrors" => true,
    "modelRun.flags.runSpinup" => true,
    "modelRun.flags.debugit" => false,
    "spinup.flags.doSpinup" => true,
    "forcing.default_forcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl,
    "opti.constraints.oneDataPath" => obspath
);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);

info, forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));

output = setupOutput(info);

forc = getKeyedArrayFromYaxArray(forcing);
linit= createLandInit(info.pools, info.tem);

loc_space_maps, land_init_space, f_one  = prepRunEcosystem(output.data, output.land_init, info.tem.models.forward, forc, forcing.sizes, info.tem);

observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)));
obs = getKeyedArrayFromYaxArray(observations);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, loc_space_maps, land_init_space, f_one)

@time outcubes = runExperimentForward(experiment_json; replace_info=replace_info);  


@time outparams = runExperimentOpti(experiment_json; replace_info=replace_info);  

tblParams = Sindbad.getParameters(info.tem.models.forward, info.optim.default_parameter, info.optim.optimized_parameters);
new_models = updateModelParameters(tblParams, info.tem.models.forward, outparams);
output = setupOutput(info);
@time runEcosystem!(output.data, new_models, forc, info.tem, loc_space_maps, land_init_space, f_one)


# some plots
using Plots
ds = forcing.data[1];
opt_dat = output.data;
def_dat = outcubes;
out_vars = output.variables;
for (vi, v) in enumerate(out_vars)
    def_var = def_dat[vi][:,1,1,1]
    opt_var = opt_dat[vi][:,1,1,1]
    plot(def_var, label="def")
    plot!(opt_var, label="opt")
    if v in propertynames(obs)
        obs_var = getfield(obs, v)[:,1,1,1]
        plot!(obs_var, label="obs")
    end
    savefig("wroasted_$(v).png")
end


lsm = loc_space_maps[1]
@time lo=map(obs) do o
    map(lsm) do ls
        view(o; first(ls) => last(ls));
    end
end;

@code_warntype getLocForc(forc, loc_space_maps[1]);
@time loc_forcing = getLocForc(forc, loc_space_maps[1]);
lsm=Tuple(loc_space_maps[1])
@time loc_forcing = getLocForc(forc, lsm);

@code_warntype getLocOut(output.data, loc_space_maps[1]);

@time loc_output = getLocOut(output.data, loc_space_maps[1]);
ar_inds = Tuple(last.(loc_space_maps[1]))
@btime getLocOut!($output.data, $ar_inds, $loc_output);

function getLocForc(forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        a=view(a; loc_space_map...)
    end
    return loc_forcing
end


function getLocForc(forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        a=view(a; loc_space_map...)
    end
    return loc_forcing

end


function getLocOut!(outcubes, ar_inds, loc_output)
    for i in eachindex(loc_output)
        loc_output[i] = getArrayView(outcubes[i], ar_inds)
    end
end

function getLocOut(outcubes, loc_space_map)
    ar_inds = Tuple(last.(loc_space_map))
    loc_output = map(outcubes) do a
        getArrayView(a, ar_inds)
    end
    return loc_output
end
a=obs.gpp;
flsm(l) = Pair(first(l), last(l))
typeof(flsm(lsm[1]))

a[flsm(lsm[1])]
foreach(lsm) do l
    # @show l, first(l), last(l)
    # f = first(l)
    # n = last(l)
    @show a[flsm(l)]
end

