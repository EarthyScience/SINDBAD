export gppAirT_none

struct gppAirT_none <: gppAirT
end

function precompute(o::gppAirT_none, forcing, land, infotem)

	## calculate variables
	# set scalar to a constant one [no effect on potential GPP]
	TempScGPP = infotem.helpers.one

	## pack land variables
	@pack_land TempScGPP => land.gppAirT
	return land
end

@doc """
set the temperature stress on gppPot to ones (no stress)

---

# compute:
Effect of temperature using gppAirT_none

*Inputs*
 - info

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP
 -

# precompute:
precompute/instantiate time-invariant variables for gppAirT_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppAirT_none