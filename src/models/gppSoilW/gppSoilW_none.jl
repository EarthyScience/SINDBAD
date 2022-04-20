export gppSoilW_none

struct gppSoilW_none <: gppSoilW
end

function precompute(o::gppSoilW_none, forcing, land, helpers)

	## calculate variables
	# set scalar to a constant one [no effect on potential GPP]
	SMScGPP = helpers.numbers.one

	## pack land variables
	@pack_land SMScGPP => land.gppSoilW
	return land
end

@doc """
set the soil moisture stress on gppPot to ones (no stress)

---

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_none

*Inputs*
 - info

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP [] dimensionless, between 0-1
 -

# precompute:
precompute/instantiate time-invariant variables for gppSoilW_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppSoilW_none