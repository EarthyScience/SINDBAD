export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties
end

function precompute(o::cTauVegProperties_none, forcing, land, helpers)
    @unpack_land (𝟘, 𝟙, numType) ∈ helpers.numbers

    ## calculate variables
    p_kfVeg = zero(land.pools.cEco) .+ helpers.numbers.𝟙
    p_LITC2N = 𝟘 
    p_LIGNIN = 𝟘 
    p_MTF = 𝟙
    p_SCLIGNIN = 𝟘 
    p_LIGEFF = 𝟘 

    ## pack land variables
    @pack_land (p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) => land.cTauVegProperties
    return land
end

@doc """
set the outputs to ones

# precompute:
precompute/instantiate time-invariant variables for cTauVegProperties_none


---

# Extended help
"""
cTauVegProperties_none