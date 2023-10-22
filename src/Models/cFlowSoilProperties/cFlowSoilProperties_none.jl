export cFlowSoilProperties_none

struct cFlowSoilProperties_none <: cFlowSoilProperties end

function define(params::cFlowSoilProperties_none, forcing, land, helpers)
    @unpack_land begin
        c_taker ∈ land.constants
        cEco ∈ land.pools
    end 
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
    @pack_land (p_E_vec, p_F_vec) → land.diagnostics
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
