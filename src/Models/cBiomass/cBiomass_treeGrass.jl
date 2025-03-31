export cBiomass_treeGrass

struct cBiomass_treeGrass <: cBiomass end

function compute(params::cBiomass_treeGrass, forcing, land, helpers)

    @unpack_nt (cVegWood, cVegLeaf) ⇐ land.pools
    @unpack_nt frac_tree ⇐ land.states

    ## calculate variables    
    cVegLeaf_sum = totalS(cVegLeaf)
    cVegWood_sum = totalS(cVegWood)
    aboveground_biomass = cVegWood_sum + cVegLeaf_sum # the assumption is that the wood and leaf pools are aboveground!
    aboveground_biomass = frac_tree > 0 ? aboveground_biomass : cVegWood_sum

    @pack_nt begin
        aboveground_biomass ⇒ land.states
    end
    return land
end

@doc """
Compute aboveground_biomass

    This serves the in situ optimization of eddy covariance sites when using AGB as a constraint. In locations where tree cover is not zero, AGB = leaf + wood. In locations where is only grass, there are no observational constraints for AGB. AGB from EO mostly refers to forested locations. To ensure that the parameter set that emerges from optimization does not generate wood, while not assuming any prior on mass of leafs, the aboveground biomass of grasses is set to the wood value, that will be constrained against a pseudo-observational value close to 0. One expects that after optimization, cVegWood_sum will be close to 0 in locations where frac_tree = 0.

# Parameters
$(SindbadParameters)

---

Inputs:
- frac_tree
- cVegWood
- cVegLeaf

Outputs:
- aboveground_biomass

"""
cBiomass_treeGrass