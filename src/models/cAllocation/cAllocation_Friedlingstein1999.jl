export cAllocation_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocation_Friedlingstein1999{T1, T2, T3} <: cAllocation
	so::T1 = 0.3 | (0.0, 1.0) | "" | ""
	ro::T2 = 0.3 | (0.0, 1.0) | "" | ""
	RelY::T3 = 2.0 | (1.0, Inf) | "" | ""
end

function precompute(o::cAllocation_Friedlingstein1999, forcing, land, helpers)
	@unpack_cAllocation_Friedlingstein1999 o

	## instantiate variables
	cAlloc = zeros(helpers.numbers.numType, helpers.pools.water.nZix.cEco); #sujan

	## pack land variables
	@pack_land cAlloc => land.cAllocation
	return land
end

function compute(o::cAllocation_Friedlingstein1999, forcing, land, helpers)
	## unpack parameters
	@unpack_cAllocation_Friedlingstein1999 o

	## unpack land variables
	@unpack_land cAlloc ∈ land.cAllocation

	## unpack land variables
	@unpack_land begin
		minWLNL ∈ land.cAllocationNutrients
		LL ∈ land.cAllocationLAI
	end
	# allocation to root; wood & leaf
	cf2.cVegRoot = ro * (RelY + 1) * LL / (LL + RelY * minWLNL)
	cf2.cVegWood = so * (RelY + 1) * minWLNL / (RelY * LL + minWLNL)
	cf2.cVegLeaf = 1 - cf2.cVegRoot - cf2.cVegWood
	# distribute the allocation according to pools
	cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
	for cpName in cpNames
		zixVec = getfield(helpers.pools.carbon.zix, cpName)
		N = length(zixVec)
		for zix in zixVec
			cAlloc[zix] = getfield(cf2, cpName) / N
		end
	end

	## pack land variables
	@pack_land cAlloc => land.states
	return land
end

@doc """
compute the fraction of NPP that is allocated to the different plant organs following the scheme of Friedlingstein et al 1999. Check cAlloc_Friedlingstein1999 for details.

# Parameters
$(PARAMFIELDS)

---

# compute:
Combine the different effects of carbon allocation using cAllocation_Friedlingstein1999

*Inputs*
 - land.cAllocationLAI.LL: values for light limitation
 - land.cAllocationNutrients.minWLNL: values for the pseudo-nutrient limitation

*Outputs*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.cAlloc

# precompute:
precompute/instantiate time-invariant variables for cAllocation_Friedlingstein1999


---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocation_Friedlingstein1999