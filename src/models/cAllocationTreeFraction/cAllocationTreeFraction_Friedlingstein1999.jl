export cAllocationTreeFraction_Friedlingstein1999, cAllocationTreeFraction_Friedlingstein1999_h
"""
adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning. adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationTreeFraction_Friedlingstein1999{T1} <: cAllocationTreeFraction
	Rf2Rc::T1 = 1.0 | (0.0, 1.0) | "fine root to coarse root fraction" | "fraction"
end

function precompute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationTreeFraction_Friedlingstein1999 o
	return land
end

function compute(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, infotem)
	@unpack_cAllocationTreeFraction_Friedlingstein1999 o

	## unpack variables
	@unpack_land begin
		(cAlloc, treeFraction) ∈ land.states
	end
	# check if there are fine & coarse root pools
	if isfield(infotem.pools.carbon.components, :cVegWoodC) && isfield(infotem.pools.carbon.components, :cVegWoodF)
		cpNames = [:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf]
		zixVecs = [
		infotem.pools.carbon.zix.cVegRootF
		infotem.pools.carbon.zix.cVegRootC
		infotem.pools.carbon.zix.cVegWood
		infotem.pools.carbon.zix.cVegLeaf
		]
	else
		cpNames = [:cVegRoot, :cVegWood, :cVegLeaf]
		zixVecs = [
		infotem.pools.carbon.zix.cVegRoot
		infotem.pools.carbon.zix.cVegWood
		infotem.pools.carbon.zix.cVegLeaf
		]
	end
	p_cVegZix = zixVecs
	p_cVegName = cpNames
	# for cp = 1:length(cpNames)
	# zix = infotem.pools.carbon.zix.(cpNames[cp])
	# p_cVegZix[cp] = zix
	# end
	# TreeFrac & fine to coarse root ratio
	tc = treeFraction
	rf2rc = Rf2Rc
	# the allocation fractions according to the partitioning to root/wood/leaf
	# - represents plant level allocation
	r0 = sum(cAlloc[infotem.pools.carbon.zix.cVegRoot]); # this is to below ground root fine+coarse
	s0 = sum(cAlloc[infotem.pools.carbon.zix.cVegWood])
	l0 = sum(cAlloc[infotem.pools.carbon.zix.cVegLeaf])
	# adjust for spatial consideration of TreeFrac & plant level
	# partitioning between fine & coarse roots
	cF.cVegWood = tc
	cF.cVegRootF = tc * rf2rc + (r0 + s0 * (r0 / (r0 + l0))) * (1.0 - tc)
	cF.cVegRootC = tc * (1.0 - rf2rc)
	cF.cVegRoot = cF.cVegRootF + cF.cVegRootC
	cF.cVegLeaf = tc + (l0 + s0 * (l0 / (r0 + l0))) * (1.0 - tc)
	# adjust the allocation parameters
	for cpN in 1:length(p_cVegName)
		cpName = p_cVegName[cpN]
		zix = p_cVegZix[cpN]
		cAlloc[zix] = cF.(cpName) * cAlloc[zix]
	end
	# for cp = p_cVegName
	# zix = infotem.pools.carbon.zix.(cp)
	# cAlloc[zix] = cF.(cp) * cAlloc[zix]
	# end
	# originally before 2020-11-05
	# check if there are fine & coarse root pools
	# if isfield(infotem.pools.carbon.components, :cVegWoodC) && # isfield(infotem.pools.carbon.components, :cVegWoodF)
	# cpNames = (:cVegRootF, :cVegRootC, :cVegWood, :cVegLeaf)
	# else
	# cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
	# end
	# # adjust the allocation parameters
	# for cp = cpNames
	# zix = infotem.pools.carbon.zix.(cp)
	# cAlloc[zix] = cF.(cp) * cAlloc[zix]
	# end

	## pack variables
	@pack_land begin
		(p_cVegName, p_cVegZix) ∋ land.cAllocationTreeFraction
		cAlloc ∋ land.states
	end
	return land
end

function update(o::cAllocationTreeFraction_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationTreeFraction_Friedlingstein1999 o
	return land
end

"""
adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning. adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning

# precompute:
precompute/instantiate time-invariant variables for cAllocationTreeFraction_Friedlingstein1999

# compute:
Adjustment of carbon allocation according to tree cover using cAllocationTreeFraction_Friedlingstein1999

*Inputs:*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.treeFraction: values for tree cover

*Outputs:*
 - land.states.cAlloc: adjusted fraction of NPP that is allocated to the different plant organs

# update
update pools and states in cAllocationTreeFraction_Friedlingstein1999
 - land.states.cAlloc

# Extended help

*References:*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cAllocationTreeFraction_Friedlingstein1999_h end