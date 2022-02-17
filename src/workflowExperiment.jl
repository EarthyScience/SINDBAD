using Revise
using Sinbad
using Test

m1 = rainSnow()
m2 = snowMelt()
m3 = evapSoil()
m4 = transpiration()
m5 = updateState()
models = (m1, m2, m3, m4, m5)
forcing, timesteps = getforcing()
outTable = evolveEcosystem(forcing, models, timesteps)

vname=:wSnow
plot(@eval outTable.$(vname))

using GR
for vname in propertynames(outTable)
    plot(@eval outTable.$(vname))
end