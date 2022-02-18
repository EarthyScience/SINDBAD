# data with NCDatasets
using NCDatasets, UnicodePlots, TypedTables

namedPairs = Dict()
namedPairs["rain"] = "P_DayMean_FLUXNET_gapfilled"
namedPairs["Tair"] = "TA_DayMean_FLUXNET_gapfilled"
namedPairs["Rn"] = "SW_IN_DayMean_FLUXNET_gapfilled"

function getforcing(; filename = "../../data/BE-Vie.2000-2019.nc",
    vars = ("rain", "Tair", "Rn"), namedPairs = namedPairs)
    ds = NCDatasets.Dataset(filename)
    names = [Symbol(vars[i]) for i in 1:length(vars)]
    values = [ds[namedPairs[vars[i]]][1, 1, :] for i in 1:length(vars)]
    forcing = Table((; zip(names, values)...)) # NCDatasets
    timesteps = size(forcing)[1]
    return forcing, timesteps
end