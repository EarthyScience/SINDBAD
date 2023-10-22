export cFlowSoilProperties_none

struct cFlowSoilProperties_none <: cFlowSoilProperties end

function define(params::cFlowSoilProperties_none, forcing, land, helpers)
    @unpack_land c_taker ∈ land.constants

    ## calculate variables
    p_E_vec = eltype(land.pools.cEco).(zero([c_taker...]))

    if land.pools.cEco isa SVector
        p_E_vec = SVector{length(p_E_vec)}(p_E_vec)
    end

    p_F_vec = eltype(land.pools.cEco).(zero([c_taker...]))
    if land.pools.cEco isa SVector
        p_F_vec = SVector{length(p_F_vec)}(p_F_vec)
    end

    ## pack land variables
    @pack_land (p_E_vec, p_F_vec) → land.cFlowSoilProperties
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# instantiate:
instantiate/instantiate time-invariant variables for cFlowSoilProperties_none


---

# Extended help
"""
cFlowSoilProperties_none
