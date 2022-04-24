export gppDirRadiation_none

struct gppDirRadiation_none <: gppDirRadiation
end

function precompute(o::gppDirRadiation_none, forcing, land, helpers)

	## calculate variables
	LightScGPP = helpers.numbers.one

	## pack land variables
	@pack_land LightScGPP => land.gppDirRadiation
	return land
end

@doc """
sets the light saturation scalar [light effect] on gppPot to one

---

# compute:
Effect of direct radiation using gppDirRadiation_none

*Inputs*
 - helpers

*Outputs*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP

# precompute:
precompute/instantiate time-invariant variables for gppDirRadiation_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarval
"""
gppDirRadiation_none