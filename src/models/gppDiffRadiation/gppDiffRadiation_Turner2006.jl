export gppDiffRadiation_Turner2006

@bounds @describe @units @with_kw struct gppDiffRadiation_Turner2006{T1} <: gppDiffRadiation
	rueRatio::T1 = 0.5 | (0.0001, 1.0) | "ratio of clear sky LUE to max LUE" | ""
end

function compute(o::gppDiffRadiation_Turner2006, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppDiffRadiation_Turner2006 o
	@unpack_forcing (Rg, RgPot) ∈ forcing


	## calculate variables
	CI = infotem.helpers.zero
	valid = RgPot > 0.0;
	CI[valid] = Rg[valid] / RgPot[valid]
	SCI = (CI - minimum(CI, 2)) / (maximum(CI, 2) - minimum(CI, 2))
	CloudScGPP = (1.0 - rueRatio) * SCI + rueRatio

	## pack land variables
	@pack_land CloudScGPP => land.gppDiffRadiation
	return land
end

@doc """
calculate the cloudiness scalar [radiation diffusion] on gppPot

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of diffuse radiation using gppDiffRadiation_Turner2006

*Inputs*
 - forcing.Rg: Global radiation [SW incoming] [MJ/m2/time]
 - forcing.RgPot: Potential radiation [MJ/m2/time]

*Outputs*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP
 -

---

# Extended help

*References*
 - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance & interannual variation in  climate on regional NEP. Tellus B: Chemical & Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_Turner2006