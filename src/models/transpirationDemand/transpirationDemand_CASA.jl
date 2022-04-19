export transpirationDemand_CASA

struct transpirationDemand_CASA <: transpirationDemand
end

function compute(o::transpirationDemand_CASA, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		pawAct ∈ land.states
		(p_wAWC, p_α, p_β) ∈ land.soilWBase
		soilWPerc ∈ land.fluxes
		PET ∈ land.PET
	end
	VMC = min(max(sum(pawAct), infotem.helpers.zero) / sum(p_wAWC), 1)
	RDR = (1 + mean(p_α, 2)) / (1 + mean(p_α, 2) * (VMC ^ mean(p_β, 2)))
	tranDem = soilWPerc + (PET - soilWPerc) * RDR

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
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_[α/β]: moisture retention characteristics
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.pawAct: actual extractable water

*Outputs*
 - land.transpirationSupply.tranSup: supply limited transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: split the original tranSup of CASA into demand  supply: actual [minimum] is now just demSup approach of transpiration  

*Created by:*
 - ncarval
 - skoirala

*Notes*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
transpirationDemand_CASA