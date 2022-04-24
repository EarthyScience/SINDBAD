export gppDiffRadiation_none

struct gppDiffRadiation_none <: gppDiffRadiation
end

function precompute(o::gppDiffRadiation_none, forcing, land, helpers)

	## calculate variables
	# set scalar to a constant one [no effect on potential GPP]
	CloudScGPP = helpers.numbers.one

	## pack land variables
	@pack_land CloudScGPP => land.gppDiffRadiation
	return land
end

@doc """
sets the cloudiness scalar [radiation diffusion] for gppPot to one

---

# compute:
Effect of diffuse radiation using gppDiffRadiation_none

*Inputs*
 - helpers

*Outputs*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP

# precompute:
precompute/instantiate time-invariant variables for gppDiffRadiation_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_none