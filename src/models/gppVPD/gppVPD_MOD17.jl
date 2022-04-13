export gppVPD_MOD17, gppVPD_MOD17_h
"""
calculate the VPD stress on gppPot based on MOD17 model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppVPD_MOD17{T1, T2} <: gppVPD
	VPDmax::T1 = 4.0 | (2.0, 8.0) | "Max VPD with GPP > 0" | "kPa"
	VPDmin::T2 = 0.65 | (0.0, 1.0) | "Min VPD with GPP > 0" | "kPa"
end

function precompute(o::gppVPD_MOD17, forcing, land, infotem)
	# @unpack_gppVPD_MOD17 o
	return land
end

function compute(o::gppVPD_MOD17, forcing, land, infotem)
	@unpack_gppVPD_MOD17 o

	## unpack variables
	@unpack_land begin
		VPDDay ∈ forcing
	end
	tmp = 1.0
	td = (VPDmax - VPDmin) * tmp
	pVPDmax = VPDmax * tmp
	vsc = (pVPDmax - VPDDay) / td
	vsc[vsc < 0.0] = 0.0
	vsc[vsc > 1] = 1
	VPDScGPP = vsc

	## pack variables
	@pack_land begin
		VPDScGPP ∋ land.gppVPD
	end
	return land
end

function update(o::gppVPD_MOD17, forcing, land, infotem)
	# @unpack_gppVPD_MOD17 o
	return land
end

"""
calculate the VPD stress on gppPot based on MOD17 model

# precompute:
precompute/instantiate time-invariant variables for gppVPD_MOD17

# compute:
Vpd effect using gppVPD_MOD17

*Inputs:*
 - forcing. VPDDay: daytime vapor pressure deficit [kPa]

*Outputs:*
 - land.gppVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1

# update
update pools and states in gppVPD_MOD17
 -

# Extended help

*References:*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of  global terrestrial primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005)  Improvements of the MODIS terrestrial gross & net primary production  global data set. Remote sensing of Environment, 95[2], 164-176.

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function gppVPD_MOD17_h end