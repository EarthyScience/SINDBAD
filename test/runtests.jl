using Sinbad
using Test
using Unitful

# setup
#o1 = rainSnow()
#o2 = snowMelt()
#o3 = snowMeltSimple()

#Model(o1)
#run!(o1)
# test operation with units and without units.
# run full model altogether.

@testset "rainSnow" begin
    @test typeof(rainSnow()) == rainSnow
    @test typeof(snowMelt()) == snowMelt
end
