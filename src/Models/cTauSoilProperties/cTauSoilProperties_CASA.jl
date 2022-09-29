export cTauSoilProperties_CASA

@bounds @describe @units @with_kw struct cTauSoilProperties_CASA{T1} <: cTauSoilProperties
	TEXTEFFA::T1 = 0.75f0 | (0.0f0, 1.0f0) | "effect of soil texture on turnove times" | ""
end

function precompute(o::cTauSoilProperties_CASA, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_cTauSoilProperties_CASA o

	## instantiate variables
	p_kfSoil = ones(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land p_kfSoil => land.cTauSoilProperties
	return land
end

function compute(o::cTauSoilProperties_CASA, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_cTauSoilProperties_CASA o

	## unpack land variables
	@unpack_land p_kfSoil ∈ land.cTauSoilProperties

	## unpack land variables
	@unpack_land (p_CLAY, p_SILT) ∈ land.soilWBase


	## calculate variables
	#sujan: moving clay & silt from land.soilTexture to p_soilWBase.
	CLAY = mean(p_CLAY)
	SILT = mean(p_SILT)
	# TEXTURE EFFECT ON k OF cMicSoil
	zix = helpers.pools.carbon.zix.cMicSoil
	p_kfSoil[zix] = (1.0f0 - (TEXTEFFA * (SILT + CLAY)))
	# (ineficient, should be pix zix_mic)

	## pack land variables
	@pack_land p_kfSoil => land.cTauSoilProperties
	return land
end

@doc """
Compute soil texture effects on turnover rates [k] of cMicSoil

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil texture on soil decomposition rates using cTauSoilProperties_CASA

*Inputs*
 - land.soilWBase.p_CLAY: values for clay soil texture
 - land.soilWBase.p_SILT: values for silt soil texture

*Outputs*
 - land.cTauSoilProperties.p_kfSoil: Soil texture stressor values on the the turnover rates

# precompute:
precompute/instantiate time-invariant variables for cTauSoilProperties_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cTauSoilProperties_CASA