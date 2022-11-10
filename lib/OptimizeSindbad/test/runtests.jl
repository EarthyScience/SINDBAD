using Sindbad
using Test

using Sindbad.Models: rainSnow_Tair

rainSnow_Tair()

m1 =  rainSnow()
m2 = snowMelt()
m3 = evaporation()
m4 = transpiration()
mlast = updateState()
forcing, timesteps = getforcing()
#outTime = evolveEcosystem(forcing, models, timesteps)

@testset "Sindbad.jl" begin
    n = 100
    m1 = rainSnow()
    m2 = snowMelt()
    models = (m1, m2)
    variables = [:rain, :Tair, :Rn]
    values = [rand(100), rand(100), rand(100)]
    forcing = Table((; zip(variables, values)...))
    timesteps = length(forcing)
    outTime = runModels(forcing, models, timesteps)

    @test m1.Tair_thres == 0.5
    @test m2.melt_T == 3.0
    @test size(outTime)[1] == n
end
