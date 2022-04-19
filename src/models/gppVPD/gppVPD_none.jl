export gppVPD_none

struct gppVPD_none <: gppVPD
end

function precompute(o::gppVPD_none, forcing, land, infotem)

	## calculate variables
	# set scalar to a constant one [no effect on potential GPP]
	VPDScGPP = infotem.helpers.one

	## pack land variables
	@pack_land VPDScGPP => land.gppVPD
	return land
end

@doc """
set the VPD stress on gppPot to ones (no stress)

---

# compute:
Vpd effect using gppVPD_none

*Inputs*
 - info

*Outputs*
 - land.gppVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1
 -

# precompute:
precompute/instantiate time-invariant variables for gppVPD_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppVPD_none