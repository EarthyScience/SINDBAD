export runoffSaturationExcess_wSoilSatFraction

struct runoffSaturationExcess_wSoilSatFraction <: runoffSaturationExcess
end

function compute(o::runoffSaturationExcess_wSoilSatFraction, forcing, land, helpers)

	## unpack land variables
	@unpack_land (WBP, soilWSatFrac) ∈ land.states


	## calculate variables
	runoffSaturation = WBP * soilWSatFrac
	# update the WBP
	WBP = WBP - runoffSaturation

	## pack land variables
	@pack_land begin
		runoffSaturation => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
calculate the saturation excess runoff as a fraction of

---

# compute:
Saturation runoff using runoffSaturationExcess_wSoilSatFraction

*Inputs*
 - land.states.WBP: amount of incoming water
 - land.states.soilWSatFrac: fraction of the grid cell that is saturated

*Outputs*
 - land.fluxes.runoffSaturation: saturation excess runoff in mm/day
 - land.states.WBP

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala

*Notes*
 - only works if soilWSatFrac module is activated
"""
runoffSaturationExcess_wSoilSatFraction