export transpiration_demandSupply

struct transpiration_demandSupply <: transpiration
end

function compute(o::transpiration_demandSupply, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		tranSup ∈ land.transpirationSupply
		tranDem ∈ land.transpirationDemand
	end
	
	transpiration = min(tranDem, tranSup)

	## pack land variables
	@pack_land transpiration => land.fluxes
	return land
end

@doc """
calculate the actual transpiration as the minimum of the supply & demand

---

# compute:
If coupled, computed from gpp and aoe from wue using transpiration_demandSupply

*Inputs*
 - land.transpirationDemand.tranDem: climate demand driven transpiration
 - land.transpirationSupply.tranSup: supply limited transpiration

*Outputs*
 - land.fluxes.transpiration: actual transpiration
 -

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - skoirala

*Notes*
 - ignores biological limitation of transpiration demand
"""
transpiration_demandSupply