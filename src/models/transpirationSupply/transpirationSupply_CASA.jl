export transpirationSupply_CASA

struct transpirationSupply_CASA <: transpirationSupply
end

function compute(o::transpirationSupply_CASA, forcing, land, helpers)

	## unpack land variables
	@unpack_land PAW ∈ land.states


	## calculate variables
	tranSup = sum(PAW)

	## pack land variables
	@pack_land tranSup => land.transpirationSupply
	return land
end

@doc """
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

---

# compute:
Supply-limited transpiration using transpirationSupply_CASA

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.soilWBase.p_[α/β]: moisture retention characteristics
 - land.soilWBase.p_wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

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
transpirationSupply_CASA