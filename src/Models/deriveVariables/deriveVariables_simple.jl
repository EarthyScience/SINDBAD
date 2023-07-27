export deriveVariables_simple

struct deriveVariables_simple <: deriveVariables end

function compute(p_struct::deriveVariables_simple, forcing, land, helpers)
    @unpack_land cEco ∈ land.pools
    ## calculate variables

    aboveground_biomass = info.tem.helpers.pools.zix.cVegWood[1]

    @pack_land aboveground_biomass => land.deriveVariables
    return land
end

@doc """
derives variables from other sindbad models and saves them into land.deriveVariables

---

# compute:

*Inputs*

*Outputs*


# Extended help

*References*

*Versions*
 - 1.0 on 19.07.2023 [skoirala]:

*Created by:*
 - skoirala
"""
deriveVariables_simple
