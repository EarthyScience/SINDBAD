export cAllocation_fixed

@bounds @describe @units @with_kw struct cAllocation_fixed{T1, T2, T3} <: cAllocation
	cVegRoot::T1 = 0.3 | (0.0, 1.0) | "fraction of NPP to cRoot" | "fraction"
	cVegWood::T2 = 0.3 | (0.0, 1.0) | "fraction of NPP to cWood" | "fraction"
	cVegLeaf::T3 = 0.4 | (0.0, 1.0) | "fraction of NPP to cLeaf" | "fraction"
end

function precompute(o::cAllocation_fixed, forcing, land, helpers)
	@unpack_cAllocation_fixed o

	## instantiate variables
	cAlloc = zeros(helpers.numbers.numType, length(land.pools.cEco))

	## pack land variables
	@pack_land cAlloc => land.cAllocation
	return land
end

function compute(o::cAllocation_fixed, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_cAllocation_fixed o

	## unpack land variables
	@unpack_land cAlloc ∈ land.cAllocation

	# distribute the allocation according to pools
	cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
	for cpName in cpNames
		zixVec = getfield(helpers.pools.carbon.zix, cpName)
		cAlloc[zix] .= getfield(o, cpName) / length(zixVec)
	end

	## pack land variables
	@pack_land cAlloc => land.states
	return land
end

@doc """
compute the fraction of NPP that is allocated to the different plant organs. In this case; the allocation is fixed in time according to the parameters in These parameters are adjusted according to the TreeFrac fraction (land.states.treeFraction). Allocation to roots is partitioned into fine [cf2Root] & coarse roots (cf2RootCoarse) according to Rf2Rc.

# Parameters
$(PARAMFIELDS)

---

# compute:
Combine the different effects of carbon allocation using cAllocation_fixed

*Inputs*
 - land.cAlloc: fraction of NPP that is allocated to the  different plant organs

*Outputs*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.cAlloc

# precompute:
precompute/instantiate time-invariant variables for cAllocation_fixed


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Ciais; P.; Collatz; G.; Mahecha; M. D.  Montagnani; L.; Papale; D.; Rambal; S.; & Seixas; J.: Identification of  Vegetation & Soil Carbon Pools out of Equilibrium in a Process Model  via Eddy Covariance & Biometric Constraints; Glob. Change Biol.; 16  2813?2829; doi: 10.1111/j.1365-2486.2009.2173.x; 2010.#
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocation_fixed