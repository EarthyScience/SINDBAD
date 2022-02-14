using Sinbad
using Test

m1 = rainSnow()
m2 = snowMelt()
models = (m1, m2)

forcing, timesteps = getforcing()

outTime = evolveEcosystem(forcing, models, timesteps)

@testset "Sinbad.jl" begin
    println("Hello, Sinbad?")
end
