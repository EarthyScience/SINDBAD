export fAPAR_cVegLeaf

@bounds @describe @units @with_kw struct fAPAR_cVegLeaf{T1} <: fAPAR
	kEffExt::T1 = 0.005 | (0.0005, 0.05) | "effective light extinction coefficient" | ""
end

function compute(o::fAPAR_cVegLeaf, forcing, land, helpers)
	## unpack parameters
	@unpack_fAPAR_cVegLeaf o

	## unpack land variables
	@unpack_land begin 
		cEco ∈ land.pools
		one ∈ helpers.numbers
	end

	## calculate variables
	cVegLeafZix = helpers.pools.carbon.zix.cVegLeaf
	cVegLeaf = sum(cEco[cVegLeafZix])
	fAPAR = one - exp(-(cVegLeaf * kEffExt))

	## pack land variables
	@pack_land fAPAR => land.states
	return land
end

@doc """
Compute FAPAR based on carbon pool of the leave; SLA; kLAI

# Parameters
$(PARAMFIELDS)

---

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_cVegLeaf

*Inputs*
 - land.pools.cEco.cVegLeaf

*Outputs*
 - land.states.fAPAR: the value of fAPAR for current time step
 - land.states.fAPAR

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 24.04.2021 [skoirala]:  

*Created by:*
 - skoirala
"""
fAPAR_cVegLeaf