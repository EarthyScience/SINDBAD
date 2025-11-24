using Test
using SindbadTEM

## update model parameters
models = [rainSnow_Tair(), snowMelt_Tair()]
params = getParameters(models)