export cFlowSoilProperties_CASA

@bounds @describe @units @with_kw struct cFlowSoilProperties_CASA{T1, T2, T3, T4, T5, T6} <: cFlowSoilProperties
	effA::T1 = 0.85 | nothing | "" | ""
	effB::T2 = 0.68 | nothing | "" | ""
	effCLAY_cMicSoil_A::T3 = 0.003 | nothing | "" | ""
	effCLAY_cMicSoil_B::T4 = 0.032 | nothing | "" | ""
	effCLAY_cSoilSlow_A::T5 = 0.003 | nothing | "" | ""
	effCLAY_cSoilSlow_B::T6 = 0.009 | nothing | "" | ""
end

function precompute(o::cFlowSoilProperties_CASA, forcing, land, helpers)
	@unpack_cFlowSoilProperties_CASA o

	## instantiate variables
	p_E = repeat(zeros(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco), 1, 1, helpers.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land p_E => land.cFlowSoilProperties
	return land
end

function compute(o::cFlowSoilProperties_CASA, forcing, land, helpers)
	## unpack parameters
	@unpack_cFlowSoilProperties_CASA o

	## unpack land variables
	@unpack_land p_E ∈ land.cFlowSoilProperties

	## unpack land variables
	@unpack_land (p_CLAY, p_SILT) ∈ land.soilWBase


	## calculate variables
	# p_fSoil = zeros(length(info.tem.model.nPix), length(info.tem.model.nZix))
	# p_fSoil = zeros(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco)
	# #sujan
	p_F = p_E
	CLAY = mean(p_CLAY)
	SILT = mean(p_SILT)
	# CONTROLS FOR C FLOW TRANSFERS EFFICIENCY [E] AND FRACTION [F] BASED ON PARTICULAR TEXTURE PARAMETERS.
	# SOURCE, TARGET, VALUE [increment in E & F caused by soil properties]
	aME = [
	:cMicSoil :cSoilSlow effA - (effB * (SILT + CLAY)); :cMicSoil :cSoilOld effA - (effB * (SILT + CLAY))
	]
	aMF = [
	:cSoilSlow :cMicSoil 1 - (effCLAY_cSoilSlow_A + (effCLAY_cSoilSlow_B * CLAY)); :cSoilSlow :cSoilOld effCLAY_cSoilSlow_A + (effCLAY_cSoilSlow_B * CLAY); :cMicSoil :cSoilSlow 1 - (effCLAY_cMicSoil_A + (effCLAY_cMicSoil_B * CLAY));:cMicSoil :cSoilOld effCLAY_cMicSoil_A + (effCLAY_cMicSoil_B * CLAY)
	]
	for vn in ("E", "F")
		eval(["aM = aM" vn " "])
		for ii in 1:size(aM, 1)
			ndxSrc = helpers.pools.carbon.zix.(aM(ii, 1))
			ndxTrg = helpers.pools.carbon.zix.(aM(ii, 2))
			for iSrc in 1:length(ndxSrc)
				for iTrg in 1:length(ndxTrg)
					# (["p_cFlowSoilProperties_" vn(1]])(:, ndxTrg[iTrg], ndxSrc[iSrc]) = aM[ii, 3); #line commented for julia conversion. make sure this works.
				end
			end
		end
	end

	## pack land variables
	@pack_land (p_E, p_F) => land.cFlowSoilProperties
	return land
end

@doc """
effects of soil that change the transfers between carbon pools

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil properties on the c transfers between pools using cFlowSoilProperties_CASA

*Inputs*
 - land.soilWBase.p_CLAY: soil hydraulic properties for clay layer
 - land.soilWBase.p_SILT: soil hydraulic properties for silt layer

*Outputs*
 - land.cFlowSoilProperties.p_E: effect of soil on transfer efficiency between pools
 - land.cFlowSoilProperties.p_F: effect of soil on transfer fraction between pools
 - land.cFlowSoilProperties.p_E
 - land.cFlowSoilProperties.p_F

# precompute:
precompute/instantiate time-invariant variables for cFlowSoilProperties_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cFlowSoilProperties_CASA