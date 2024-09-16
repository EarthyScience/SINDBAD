export cFlowVegProperties_none

struct cFlowVegProperties_none <: cFlowVegProperties end

function define(params::cFlowVegProperties_none, forcing, land, helpers)
    @unpack_nt cEco ⇐ land.pools

    @unpack_nt c_taker ⇐ land.constants

    ## calculate variables
    p_E_vec = eltype(cEco).(zero([c_taker...]))

    if cEco isa SVector
        p_E_vec = SVector{length(p_E_vec)}(p_E_vec)
    end

    p_F_vec = eltype(cEco).(zero([c_taker...]))
    if cEco isa SVector
        p_F_vec = SVector{length(p_F_vec)}(p_F_vec)
    end

    ## pack land variables
    @pack_nt (p_E_vec, p_F_vec) ⇒ land.cFlowVegProperties
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
