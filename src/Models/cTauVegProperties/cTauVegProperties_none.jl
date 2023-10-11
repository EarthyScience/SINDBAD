export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties end

function define(params::cTauVegProperties_none, forcing, land, helpers)

    ## calculate variables
    c_eco_k_f_veg_props = one.(land.pools.cEco)
    LITC2N = land.wCycleBase.z_zero
    LIGNIN = land.wCycleBase.z_zero
    MTF = land.wCycleBase.o_one
    SCLIGNIN = land.wCycleBase.z_zero
    LIGEFF = land.wCycleBase.z_zero

    ## pack land variables
    @pack_land (LIGEFF, LIGNIN, LITC2N, MTF, SCLIGNIN, c_eco_k_f_veg_props) => land.cTauVegProperties
    return land
end

@doc """
set the outputs to ones

# instantiate:
instantiate/instantiate time-invariant variables for cTauVegProperties_none


---

# Extended help
"""
cTauVegProperties_none
