export runoffInfiltrationExcess_kUnsat

struct runoffInfiltrationExcess_kUnsat <: runoffInfiltrationExcess
end

function compute(o::runoffInfiltrationExcess_kUnsat, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		WBP ∈ land.states
		kUnsatFuncH ∈ land.soilProperties
	end
	# get the unsaturared hydraulic conductivity based on soil properties for the first soil layer
	k_unsat = feval(kUnsatFuncH, s, p, info, 1)
	# minimum of the conductivity & the incoming water
	runoffInfiltration = max(WBP-k_unsat, infotem.helpers.zero)
	# update remaining water
	WBP = WBP - runoffInfiltration

	## pack land variables
	@pack_land begin
		runoffInfiltration => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
calculates the infiltration excess runoff based on unsτrated hydraulic conductivity

---

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_kUnsat

*Inputs*
 - land.p.soilProperties.kUnsatFuncH: function to calculate unsaturated K: out of pSoil [Saxtion1986 | Saxton2006] end
 - land.pools.soilW of first layer

*Outputs*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 23.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
runoffInfiltrationExcess_kUnsat