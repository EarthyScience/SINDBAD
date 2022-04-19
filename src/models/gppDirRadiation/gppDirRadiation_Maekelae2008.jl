export gppDirRadiation_Maekelae2008

@bounds @describe @units @with_kw struct gppDirRadiation_Maekelae2008{T1} <: gppDirRadiation
	γ::T1 = 0.04 | (0.001, 0.1) | "empirical light response parameter" | ""
end

function compute(o::gppDirRadiation_Maekelae2008, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_gppDirRadiation_Maekelae2008 o
	@unpack_forcing PAR ∈ forcing


	## unpack land variables
	@unpack_land begin
		fAPAR ∈ land.states
		(zero, one) ∈ infotem.helpers
	end

	## calculate variables
	LightScGPP = one / (γ * PAR * fAPAR + one)

	## pack land variables
	@pack_land LightScGPP => land.gppDirRadiation
	return land
end

@doc """
calculate the light saturation scalar [light effect] on gppPot

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of direct radiation using gppDirRadiation_Maekelae2008

*Inputs*
 - forcing.PAR: photosynthetically active radiation [MJ/m2/time]
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation []
 - γ: light response curve parameter to account for light  saturation [m2/MJ-1 of APAR]. The smaller γ the smaller  the effect; no effect if it becomes 0 [i.e. linear light response]

*Outputs*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP
 -

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approach:  analysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - mjung
 - ncarval

*Notes*
 - γ is between [0.007 0.05], median !0.04 [m2/mol] in Maekelae  et al 2008.
"""
gppDirRadiation_Maekelae2008