using Test
using Sindbad.Simulation

## update model parameters
models = [rainSnow_Tair(), snowMelt_Tair()]
params = getParameters(models)