export runoffSaturationExcess_satFraction

struct runoffSaturationExcess_satFraction <: runoffSaturationExcess
end

function compute(o::runoffSaturationExcess_satFraction, forcing, land, helpers)

	## unpack land variables
	@unpack_land (WBP, satFrac) ∈ land.states


	## calculate variables
	runoffSatExc = WBP * satFrac

	# update the WBP
	WBP = WBP - runoffSatExc

	## pack land variables
	@pack_land begin
		runoffSatExc => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
saturation excess runoff as a fraction of saturated fraction of land

---

# compute:
Saturation runoff using runoffSaturationExcess_satFraction

*Inputs*
 - land.states.WBP: amount of incoming water
 - land.states.satFrac: fraction of the grid cell that is saturated from saturatedFraction model

*Outputs*
 - land.fluxes.runoffSatExc: saturation excess runoff in mm/day
 - land.states.WBP

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: cleaned up the code  

*Created by:*
 - skoirala

*Notes*
 - only works if soilWSatFrac module is activated
"""
runoffSaturationExcess_satFraction