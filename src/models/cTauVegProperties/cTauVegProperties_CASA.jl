export cTauVegProperties_CASA

@bounds @describe @units @with_kw struct cTauVegProperties_CASA{T1, T2, T3, T4, T5, T6, T7} <: cTauVegProperties
	LIGNIN_per_PFT::T1 = [0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1] | nothing | "fraction of litter that is lignin" | ""
	NONSOL2SOLLIGNIN::T2 = 2.22 | nothing | "" | ""
	MTFA::T3 = 0.85 | nothing | "" | ""
	MTFB::T4 = 0.018 | nothing | "" | ""
	C2LIGNIN::T5 = 0.65 | nothing | "" | ""
	LIGEFFA::T6 = 3.0 | nothing | "" | ""
	LITC2N_per_PFT::T7 = [40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0] | nothing | "carbon-to-nitrogen ratio in litter" | ""
end

function precompute(o::cTauVegProperties_CASA, forcing, land, helpers)
	@unpack_cTauVegProperties_CASA o

	## instantiate variables
	p_kfVeg = ones(helpers.numbers.numType, helpers.pools.water.nZix.cEco); #sujan
		annk = helpers.numbers.zero; #sujan ones(size(AGE))

	## pack land variables
	@pack_land (p_kfVeg, annk) => land.cTauVegProperties
	return land
end

function compute(o::cTauVegProperties_CASA, forcing, land, helpers)
	## unpack parameters
	@unpack_cTauVegProperties_CASA o

	## unpack land variables
	@unpack_land (p_kfVeg, annk) ∈ land.cTauVegProperties

	## unpack land variables
	@unpack_land PFT ∈ land.vegProperties


	## calculate variables
	# p_annk = annk; #sujan
	# initialize the outputs to ones
	p_C2LIGNIN = C2LIGNIN; #sujan
	## adjust the annk that are pft dependent directly on the p matrix
	pftVec = unique(PFT)
	# AGE = zeros(helpers.numbers.numType, helpers.pools.water.nZix.cEco); #sujan
	for cpN in (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
		# get average age from parameters
		AGE = helpers.numbers.zero; #sujan
		for ij in 1:length(pftVec)
			AGE[p.vegProperties.PFT == pftVec[ij]] = p.cCycleBase.([cpN "_AGE_per_PFT"])(pftVec[ij])
		end
		# compute annk based on age
		annk[AGE > 0.0] = 1.0 / AGE[AGE > 0.0]
		# feed it to the new annual turnover rates
		zix = helpers.pools.carbon.zix.(cpN)
		p_annk[zix] = annk; #sujan
		# p_annk[zix] = annk[zix]
	end
	# feed the parameters that are pft dependent.
	pftVec = unique(PFT)
	p_LITC2N = helpers.numbers.zero
	p_LIGNIN = helpers.numbers.zero
	for ij in 1:length(pftVec)
		p_LITC2N[p.vegProperties.PFT == pftVec[ij]] = LITC2N_per_PFT[pftVec[ij]]
		p_LIGNIN[p.vegProperties.PFT == pftVec[ij]] = LIGNIN_per_PFT[pftVec[ij]]
	end
	# CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
	# CALCULATE LIGNIN 2 NITROGEN SCALAR
	L2N = (p_LITC2N * p_LIGNIN) * NONSOL2SOLLIGNIN
	# DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
	MTF = MTFA - (MTFB * L2N)
	MTF[MTF < helpers.numbers.zero] = helpers.numbers.zero
	p_MTF = MTF
	# DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
	p_SCLIGNIN = (p_LIGNIN * p_C2LIGNIN * NONSOL2SOLLIGNIN) / (1.0 - MTF)
	# DETERMINE EFFECT OF LIGNIN CONTENT ON k OF cLitLeafS AND cLitRootFS
	p_LIGEFF = exp(-LIGEFFA * p_SCLIGNIN)
	# feed the output
	p_kfVeg[helpers.pools.carbon.zix.cLitLeafS] = p_LIGEFF
	p_kfVeg[helpers.pools.carbon.zix.cLitRootFS] = p_LIGEFF

	## pack land variables
	@pack_land begin
		p_annk => land.cCycleBase
		(p_C2LIGNIN, p_LIGEFF, p_LIGNIN, p_LITC2N, p_MTF, p_SCLIGNIN, p_kfVeg) => land.cTauVegProperties
	end
	return land
end

@doc """
Compute effect of vegetation type on turnover rates [k]

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of vegetation properties on soil decomposition rates using cTauVegProperties_CASA

*Inputs*
 - land.vegProperties.PFT:

*Outputs*
 - land.cTauVegProperties.p_LIGEFF:
 - land.cTauVegProperties.p_LIGNIN:
 - land.cTauVegProperties.p_LITC2N:
 - land.cTauVegProperties.p_MTF:
 - land.cTauVegProperties.p_SCLIGNIN:
 - land.cTauVegProperties.p_kfVeg:
 -

# precompute:
precompute/instantiate time-invariant variables for cTauVegProperties_CASA


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
cTauVegProperties_CASA