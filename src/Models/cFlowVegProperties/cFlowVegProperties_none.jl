export cFlowVegProperties_none

struct cFlowVegProperties_none <: cFlowVegProperties end

function define(p_struct::cFlowVegProperties_none, forcing, land, helpers)

    @unpack_land c_taker ∈ land.cCycleBase

    ## calculate variables
    p_E = helpers.numbers.sNT.(zero([c_taker...]))

    if land.pools.cEco isa SVector
        p_E = SVector{length(p_E)}(p_E)
    end

    p_F = helpers.numbers.sNT.(zero([c_taker...]))
    if land.pools.cEco isa SVector
        p_F = SVector{length(p_F)}(p_F)
    end

    ## pack land variables
    @pack_land (p_E, p_F) => land.cFlowVegProperties
    return land
end

@doc """
set transfer between pools to 0 [i.e. nothing is transfered]

# instantiate:
instantiate/instantiate time-invariant variables for cFlowVegProperties_none


---

# Extended help
"""
cFlowVegProperties_none
