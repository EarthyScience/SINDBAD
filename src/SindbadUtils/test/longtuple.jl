using Sindbad
using SindbadUtils: makeLongTuple, getTupleFromLongTuple
using Test

@testset "SindbadUtils: LongTuple" begin
    # define a toy tuple of models
    models_set = (rainSnow_Tair(), ambientCO2_constant(), cAllocation_fixed(),
    cCycle_simple(), fAPAR_constant(), gpp_coupled(), PFT_constant(), cCycleBase_CASA())
    # create a LongTuple
    long_tpl = makeLongTuple(models_set)
    # range
    tpl_range = getTupleFromLongTuple(long_tpl[5:end]) # and get a normal tuple for testing

    @test long_tpl[1] == models_set[1]
    @test tpl_range == models_set[5:end]
    @test_throws ErrorException long_tpl[9] # tests Index out of bounds 
end
