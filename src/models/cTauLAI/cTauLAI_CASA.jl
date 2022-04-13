export cTauLAI_CASA, cTauLAI_CASA_h
"""
calc LAI stressor on τ. Compute the seasonal cycle of litter fall & root litter "fall" based on LAI variations. Necessarily in precomputation mode

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauLAI_CASA{T1, T2} <: cTauLAI
	maxMinLAI::T1 = 12.0 | (11.0, 13.0) | "maximum value for the minimum LAI for litter scalars" | "m2/m2"
	kRTLAI::T2 = 0.3 | (0.0, 1.0) | "constant fraction of root litter imputs" | ""
end

function precompute(o::cTauLAI_CASA, forcing, land, infotem)
	@unpack_cTauLAI_CASA o

	## instantiate variables
	p_kfLAI = ones(size(infotem.pools.carbon.initValues.cEco)); #(inefficient, should be pix zix_veg)

	## pack variables
	@pack_land begin
		p_kfLAI ∋ land.cTauLAI
	end
	return land
end

function compute(o::cTauLAI_CASA, forcing, land, infotem)
	@unpack_cTauLAI_CASA o

	## unpack variables
	@unpack_land begin
		p_kfLAI ∈ land.cTauLAI
		LAI ∈ land.states
		(p_annk, p_k) ∈ land.cCycleBase
	end
	# set LAI stressor on τ to ones
	TSPY = infotem.dates.nStepsYear; #sujan
	p_cVegLeafZix = infotem.pools.carbon.zix.cVegLeaf
	if isfield(infotem.pools.carbon.zix, :cVegRootF)
		p_cVegRootZix = infotem.pools.carbon.zix.cVegRootF
	else
		p_cVegRootZix = infotem.pools.carbon.zix.cVegRoot
	end
	# make sure TSPY is integer
	TSPY = floor(Int, TSPY)
	if !hasproperty(land.cTaufLAI, :p_LAI13)
		p_LAI13 = repeat([0.0], 1, TSPY + 1)
	end
	# PARAMETERS
	#--> Get the number of time steps per year
	TSPY = infotem.dates.nStepsYear
	# make sure TSPY is integer
	TSPY = floor(Int, TSPY)
	# BUILD AN ANNUAL LAI MATRIX
	#--> get the LAI of previous time step in LAI13
	LAI13 = p_LAI13
	LAI13 = circshift(LAI13, 1, 2)
	# LAI13[2:TSPY + 1] = LAI13[1:TSPY]; # very slow [sujan]
	LAI13[1] = LAI
	LAI13_next = LAI13[2:TSPY + 1]
	# LAI13_prev = LAI13[1:TSPY]
	#--> update s
	p_LAI13 = LAI13
	#--> Calculate sum of δLAI over the year
	dLAI = diff(LAI13, 1, 2)
	dLAI = max(dLAI, 0)
	dLAIsum = sum(dLAI)
	#--> Calculate average & minimum LAI
	LAIsum = sum(LAI13_next)
	LAIave = LAIsum / size(LAI13_next, 2)
	LAImin = minimum(LAI13_next)
	LAImin[LAImin > maxMinLAI] = maxMinLAI[LAImin > maxMinLAI]
	#--> Calculate constant fraction of LAI [LTCON]
	LTCON = 0.0
	ndx = (LAIave > 0.0)
	LTCON[ndx] = LAImin[ndx] / LAIave[ndx]
	#--> Calculate δLAI
	dLAI = dLAI[1]
	#--> Calculate variable fraction of LAI [LTCON]
	LTVAR = 0.0
	LTVAR[dLAI <= 0.0 | dLAIsum <= 0.0] = 0.0
	ndx = (dLAI > 0.0 | dLAIsum > 0.0)
	LTVAR[ndx] = (dLAI[ndx] / dLAIsum[ndx])
	#--> Calculate the scalar for litterfall
	LTLAI = LTCON / TSPY + (1.0 - LTCON) * LTVAR
	#--> Calculate the scalar for root litterfall
	# RTLAI = zeros(size(LTLAI))
	RTLAI = 0.0
	ndx = (LAIsum > 0.0)
	LAI131st = LAI13[1]
	RTLAI[ndx] = (1.0 - kRTLAI) * (LTLAI[ndx] + LAI131st[ndx] / LAIsum[ndx]) / 2.0 + kRTLAI / TSPY
	#--> Feed the output fluxes to cCycle components
	zix_veg = p_cVegLeafZix
	p_kfLAI[zix_veg] = p_annk[zix_veg] * LTLAI / p_k[zix_veg]; # leaf litter scalar
	zix_root = p_cVegRootZix
	p_kfLAI[zix_root] = p_annk[zix_root] * RTLAI / p_k[zix_root]; # root litter scalar

	## pack variables
	@pack_land begin
		(p_LAI13, p_cVegLeafZix, p_cVegRootZix, p_kfLAI) ∋ land.cTauLAI
	end
	return land
end

function update(o::cTauLAI_CASA, forcing, land, infotem)
	# @unpack_cTauLAI_CASA o
	return land
end

"""
calc LAI stressor on τ. Compute the seasonal cycle of litter fall & root litter "fall" based on LAI variations. Necessarily in precomputation mode

# precompute:
precompute/instantiate time-invariant variables for cTauLAI_CASA

# compute:
Calculate litterfall scalars (that affect the changes in the vegetation k) using cTauLAI_CASA

*Inputs:*
 - forcing.LAI: leaf area index [m2/m2]
 - info.timeScale.stepsPerYear: number of years of simulations
 - infotem.dates.nStepsYear: number of years of simulations

*Outputs:*
 - land.cTauLAI.p_kfLAI:
 - land.cTauLAI.p_kfLAI: LAI stressor values on the the turnover rates based  on litter & root litter scalars

# update
update pools and states in cTauLAI_CASA
 -

# Extended help

*References:*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]
 - 1.0 on 12.01.2020 [sbesnard]  
 - 1.1 on 05.11.2020 [skoirala]: speedup  

*Created by:*
 - ncarvalhais
"""
function cTauLAI_CASA_h end