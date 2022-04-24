export transpirationDemand_CASA

struct transpirationDemand_CASA <: transpirationDemand
end

function compute(o::transpirationDemand_CASA, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		PAW ∈ land.vegAvailableWater
		(p_wAWC, p_α, p_β) ∈ land.soilWBase
		percolation ∈ land.percolation
		PET ∈ land.PET
		(zero, one) ∈ helpers.numbers
	end
	VMC = clamp(sum(PAW) / sum(p_wAWC), zero, one)
	RDR = (one + mean(p_α)) / (one + mean(p_α) * (VMC ^ mean(p_β)))
	tranDem = percolation + (PET - percolation) * RDR

	## pack land variables
	@pack_land tranDem => land.transpirationDemand
	return land
end

@doc """
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

---

# compute:
Demand-driven transpiration using transpirationDemand_CASA

*Inputs*
 - land.pools.PAW : plant avaiable water
 - land.soilWBase.p_[α/β]: moisture retention characteristics
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.tranDem.transpirationDemand: supply limited transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: split the original tranSup of CASA into demand supply: actual [minimum] is now just demandSupply approach of transpiration  

*Created by:*
 - ncarval
 - skoirala

*Notes*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
transpirationDemand_CASA