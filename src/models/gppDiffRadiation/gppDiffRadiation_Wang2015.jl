export gppDiffRadiation_Wang2015

@bounds @describe @units @with_kw struct gppDiffRadiation_Wang2015{T1} <: gppDiffRadiation
	μ::T1 = 0.46 | (0.0001, 1.0) | "" | ""
end

function compute(o::gppDiffRadiation_Wang2015, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppDiffRadiation_Wang2015 o
	@unpack_forcing (Rg, RgPot) ∈ forcing


	## calculate variables
	## FROM SHANNING
	# CI = cloudiness index
	CI = infotem.helpers.zero
	valid = RgPot > 0.0
	CI[valid] = 1 - Rg[valid] / RgPot[valid]
	CI_nor = 1.0
	yearsVec = infotem.dates.year
	yearsVec = yearsVec[1:size(CI, 2)]
	for i in unique(yearsVec)
		ndx = yearsVec == i
		CImin = min(CI[ndx], 2); #CImin is the minimum CI value of present year
		CImax = max(CI[ndx], 2)
		CI_nor[ndx] = (CI[ndx] - CImin) / (CImax - CImin)
	end
	CloudScGPP = 1 - μ * (1.0 - CI_nor)

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
Effect of diffuse radiation using gppDiffRadiation_Wang2015

*Inputs*
 - forcing.Rg: Global radiation [SW incoming] [MJ/m2/time]
 - forcing.RgPot: Potential radiation [MJ/m2/time]
 - rueRatio : ratio of clear sky LUE to max LUE  in turner et al., appendix A, e_[g_cs] / e_[g_max], should be between 0 & 1

*Outputs*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP
 -

---

# Extended help

*References*
 - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance & interannual variation in  climate on regional NEP. Tellus B: Chemical & Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]
 - 1.1 on 22.01.2021 [skoirala]: minimum & maximum function had []  missing & were not working  

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_Wang2015