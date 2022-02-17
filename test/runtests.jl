using Revise
using Sinbad
using Test

m1 =  rainSnow()
m2 = snowMelt()
m3 = evapSoil()
m4 = transpiration()
mlast = updateState()
forcing, timesteps = getforcing()
#outTime = evolveEcosystem(forcing, models, timesteps)

@testset "Sinbad.jl" begin
    n = 100
    m1 = rainSnow()
    m2 = snowMelt()
    models = (m1, m2)
    variables = [:rain, :Tair, :Rn]
    values = [rand(100), rand(100), rand(100)]
    forcing = Table((; zip(variables, values)...))
    timesteps = length(forcing)
    outTime = evolveEcosystem(forcing, models, timesteps)

    @test m1.Tair_thres == 0.5
    @test m2.melt_T == 3.0
    @test size(outTime)[1] == n
end
