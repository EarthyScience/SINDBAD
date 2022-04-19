export capillaryFlow_VanDijk2010

struct capillaryFlow_VanDijk2010 <: capillaryFlow
end

function compute(o::capillaryFlow_VanDijk2010, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		(p_kFC, p_wSat) ∈ land.soilWBase
		soilW ∈ land.pools
	end
	capFlow = repeat(infotem.helpers.azero, infotem.pools.water.nZix.soilW)
	dos_soilW = soilW ./ p_wSat
	for sl in 1:infotem.pools.water.nZix.soilW-1
		tmpCapFlow = sqrt(p_kFC[sl] * p_kFC[sl+1]) * (infotem.helpers.one - dos_soilW[sl])
		holdCap = p_wSat[sl] - soilW[sl]
		lossCap = soilW[sl+1]
		capFlow[sl] = min(tmpCapFlow, holdCap, lossCap)
	end

	## pack land variables
	@pack_land begin
		capFlow => land.capillaryFlow
	end
	return land
end

@doc """
computes the upward water flow in the soil layers

---

# compute:
Flux of water from lower to upper soil layers (upward soil moisture movement) using capillaryFlow_VanDijk2010

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs*
 -

# update

update pools and states in capillaryFlow_VanDijk2010

 - land.pools.soilW
 - land.states.soilWFlow: drainage flux between soil layers [from soilWRec] is adjusted to reflect  upward capillary flux

---

# Extended help

*References*
 - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
 - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
capillaryFlow_VanDijk2010