using Revise
using Sindbad
using ProgressMeter
Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing.data, info.tem);



output = setupOutput(info);


a=zopen("exp_mapEco/output_sandbox/output/soilW.zarr/")
dat = replace(a["layer"][4,1:365, 7,1], missing => NaN)
# Sindbad.eval(:(debugcatch = []))
# Sindbad.eval(:(debugcatcherr = []))
UnicodePlots.lineplot(dat)
@time outcubes = mapRunEcosystem(forcing, output, info.tem);
outcubes[2]
