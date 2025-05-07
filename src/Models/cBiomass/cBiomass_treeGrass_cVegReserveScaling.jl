export cBiomass_treeGrass_cVegReserveScaling


struct cBiomass_treeGrass_cVegReserveScaling <: cBiomass end

function compute(params::cBiomass_treeGrass_cVegReserveScaling, forcing, land, helpers)
    @unpack_nt (cVegWood, cVegLeaf, cVegReserve, cVegRoot) ⇐ land.pools
    @unpack_nt frac_tree ⇐ land.states

    ## calculate variables    
    cVegLeaf_sum = totalS(cVegLeaf)
    cVegWood_sum = totalS(cVegWood)
    cVegReserve_sum = totalS(cVegReserve)
    cVegRoot_sum = totalS(cVegRoot)
    aboveground_biomass = (cVegWood_sum + cVegLeaf_sum) + cVegReserve_sum * (cVegWood_sum + cVegLeaf_sum) / (cVegWood_sum + cVegLeaf_sum + cVegRoot_sum)

	
    aboveground_biomass = frac_tree > zero(frac_tree) ? aboveground_biomass : cVegWood_sum

    @pack_nt begin
        aboveground_biomass ⇒ land.states
    end

	return land
end

purpose(::Type{cBiomass_treeGrass_cVegReserveScaling}) = "same as treeGrass, but includes scaling for relative fraction of cVegReserve pool"

@doc """ 

	$(getBaseDocString(cBiomass_treeGrass_cVegReserveScaling))

---

# Extended help

*References*

*Versions*
 - 1.0 on 07.05.2025 [skoirala]

*Created by*
 - skoirala

"""
cBiomass_treeGrass_cVegReserveScaling

