export cFlowVegProperties_CASA

@bounds @describe @units @with_kw struct cFlowVegProperties_CASA{T1} <: cFlowVegProperties
	WOODLIGFRAC::T1 = 0.4 | nothing | "fraction of wood that is lignin" | ""
end

function precompute(o::cFlowVegProperties_CASA, forcing, land, helpers)
	@unpack_cFlowVegProperties_CASA o

	## instantiate variables
	p_F = repeat(zeros(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco), 1, 1, helpers.pools.carbon.nZix.cEco)

	## pack land variables
	@pack_land p_F => land.cFlowVegProperties
	return land
end

function compute(o::cFlowVegProperties_CASA, forcing, land, helpers)
	## unpack parameters
	@unpack_cFlowVegProperties_CASA o

	## unpack land variables
	@unpack_land p_F ∈ land.cFlowVegProperties

	## calculate variables
	# p_fVeg = zeros(nPix, length(info.tem.model.c.nZix)); #sujan
	#p_fVeg = zeros(helpers.numbers.numType, helpers.pools.carbon.nZix.cEco)
	p_E = p_F
	# ADJUST cFlow BASED ON PARTICULAR PARAMETERS # SOURCE, TARGET, INCREMENT aM = (:cVegLeaf, :cLitLeafM, p_MTF;, :cVegLeaf, :cLitLeafS, 1, -, p_MTF;, :cVegWood, :cLitWood, 1;, :cVegRootF, :cLitRootFM, p_MTF;, :cVegRootF, :cLitRootFS, 1, -, p_MTF;, :cVegRootC, :cLitRootC, 1;, :cLitLeafS, :cSoilSlow, p_SCLIGNIN;, :cLitLeafS, :cMicSurf, 1, -, p_SCLIGNIN;, :cLitRootFS, :cSoilSlow, p_SCLIGNIN;, :cLitRootFS, :cMicSoil, 1, -, p_SCLIGNIN;, :cLitWood, :cSoilSlow, WOODLIGFRAC;, :cLitWood, :cMicSurf, 1, -, WOODLIGFRAC;, :cLitRootC, :cSoilSlow, WOODLIGFRAC;, :cLitRootC, :cMicSoil, 1, -, WOODLIGFRAC;, :cSoilOld, :cMicSoil, 1;, :cLitLeafM, :cMicSurf, 1;, :cLitRootFM, :cMicSoil, 1;, :cMicSurf, :cSoilSlow, 1;)
	for ii in 1:size(aM, 1)
		ndxSrc = helpers.pools.carbon.zix.(aM(ii, 1))
		ndxTrg = helpers.pools.carbon.zix.(aM(ii, 2)); #sujan is this 2 | 1?
		for iSrc in 1:length(ndxSrc)
			for iTrg in 1:length(ndxTrg)
				# p_fVeg[ndxTrg[iTrg], ndxSrc[iSrc]] = aM(ii, 3)
				p_F[ndxTrg[iTrg], ndxSrc[iSrc]] = aM(ii, 3); #sujan
			end
		end
	end

	## pack land variables
	@pack_land (p_E, p_F) => land.cFlowVegProperties
	return land
end

@doc """
effects of vegetation that change the transfers between carbon pools

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of vegetation properties on the c transfers between pools using cFlowVegProperties_CASA

*Inputs*
 - land.cTauVegProperties.p_MTF: fraction of C in structural litter pools  that will be metabolic from lignin:N ratio
 - land.cTauVegProperties.p_SCLIGNIN: fraction of C in structural litter pools from lignin

*Outputs*
 - land.cFlowVegProperties.p_E: effect of vegetation on transfer efficiency between pools
 - land.cFlowVegProperties.p_F: effect of vegetation on transfer fraction between pools
 - land.cFlowVegProperties.p_E
 - land.cFlowVegProperties.p_F

# precompute:
precompute/instantiate time-invariant variables for cFlowVegProperties_CASA


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
cFlowVegProperties_CASA