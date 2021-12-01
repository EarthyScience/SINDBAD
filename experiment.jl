using Sinbad, Unitful
using NCDatasets, DataFrames
# data
filename = "./data/BE-Vie.2000-2019.nc"
ds = Dataset(filename)
x = ds["TA_DayTime_FLUXNET_gapfilled"]
y = ds["P_DayMean_FLUXNET_gapfilled"]
z = ds["SW_IN_DayMean_FLUXNET_gapfilled"]
df = DataFrame(Rain = y[1, 1, :], Tair = x[1, 1, :], Rn = z[1, 1, :])
close(ds)
# more data-friendly handling could be also added later

# setup
o1 = rainSnow()
o2 = snowMelt()
o3 = snowMeltSimple()
models = (o1, o2, o3)

#[getForcingVars(models[i]) for i = 1:3]

runEcosystem(df, models)