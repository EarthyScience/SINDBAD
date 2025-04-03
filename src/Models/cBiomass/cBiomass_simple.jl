export cBiomass_simple

struct cBiomass_simple <: cBiomass end

function compute(params::cBiomass_simple, forcing, land, helpers)
    @unpack_nt (cVegWood, cVegLeaf) ⇐ land.pools
    ## calculate variables    
    cVegLeaf_sum = totalS(cVegLeaf)
    cVegWood_sum = totalS(cVegWood)
    aboveground_biomass = cVegWood_sum + cVegLeaf_sum # the assumption is that the wood and leaf pools are aboveground!

    @pack_nt begin
        aboveground_biomass ⇒ land.states
    end
    return land
end


purpose(::Type{cBiomass_simple}) = "calculates aboveground biomass as a sum of wood and leaf carbon pools."

@doc """

$(getBaseDocString(cBiomass_simple))

---

# Extended help

*References*

*Versions*

*Created by*
"""
cBiomass_simple