import Sindbad.Models as SM

@testset "ambientCO2" verbose=true begin
    @testset "ambientCO2_constant" begin
        tmp_model = ambientCO2_constant()
        @test typeof(tmp_model) <: LandEcosystem
        @test typeof(tmp_model) <: ambientCO2
        # update land with define
        land_d = SM.define(tmp_model, tmp_forcing, tmp_land, tmp_helpers)
        land_d = SM.precompute(tmp_model, tmp_forcing, tmp_land, tmp_helpers)
        # test allocations, they should be zero!
        @test (@ballocated SM.compute($tmp_model, $tmp_forcing, $land_d, $tmp_helpers)) == 0
        # # check output
        # land = SM.compute(tmp_model, tmp_forcing, land_d, tmp_helpers)
        # # what goes in, goes out.
        # @test tmp_forcing.f_dist_intensity == land.diagnostics.c_fire_fba
    end
    @testset "ambientCO2_forcing" begin
        tmp_model = ambientCO2_forcing()
        @test typeof(tmp_model) <: LandEcosystem
        @test typeof(tmp_model) <: ambientCO2
        # update land with define
        land_d = SM.define(tmp_model, tmp_forcing, tmp_land, tmp_helpers)
        land_d = SM.precompute(tmp_model, tmp_forcing, tmp_land, tmp_helpers)
        # test allocations, they should be zero!
        @test (@ballocated SM.compute($tmp_model, $tmp_forcing, $land_d, $tmp_helpers)) == 0
        # # check output
        # land = SM.compute(tmp_model, tmp_forcing, land_d, tmp_helpers)
        # # what goes in, goes out.
        # @test tmp_forcing.f_dist_intensity == land.diagnostics.c_fire_fba
    end
end