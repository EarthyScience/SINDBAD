using Sinbad
using Test
using Unitful
using ModelParameters

#o = rainSnow()

#run!(o)
#Model(o)
#run!(o)
# test operation with units and without units.
# run full model altogether.

@testset "rainSnow" begin
    @test typeof(rainSnow()) == rainSnow
    @test typeof(snowMelt()) == snowMelt
end
