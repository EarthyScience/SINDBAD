export gppVPD_MOD17

@bounds @describe @units @with_kw struct gppVPD_MOD17{T1, T2} <: gppVPD
	VPDmax::T1 = 4.0 | (2.0, 8.0) | "Max VPD with GPP > 0" | "kPa"
	VPDmin::T2 = 0.65 | (0.0, 1.0) | "Min VPD with GPP > 0" | "kPa"
end

function compute(o::gppVPD_MOD17, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppVPD_MOD17 o
	@unpack_forcing VPDDay ∈ forcing


	## calculate variables
	tmp = 1.0
	td = (VPDmax - VPDmin) * tmp
	pVPDmax = VPDmax * tmp
	vsc = (pVPDmax - VPDDay) / td
	vsc[vsc < infotem.helpers.zero] = infotem.helpers.zero
	vsc[vsc > infotem.helpers.one] = infotem.helpers.one
	VPDScGPP = vsc

	## pack land variables
	@pack_land VPDScGPP => land.gppVPD
	return land
end

@doc """
calculate the VPD stress on gppPot based on MOD17 model

# Parameters
$(PARAMFIELDS)

---

# compute:
Vpd effect using gppVPD_MOD17

*Inputs*
 - forcing. VPDDay: daytime vapor pressure deficit [kPa]

*Outputs*
 - land.gppVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1
 -

---

# Extended help

*References*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of  global terrestrial primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005)  Improvements of the MODIS terrestrial gross & net primary production  global data set. Remote sensing of Environment, 95[2], 164-176.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppVPD_MOD17