export cAllocation_GSI

struct cAllocation_GSI <: cAllocation
end

function precompute(o::cAllocation_GSI, forcing, land, infotem)

	## instantiate variables
	cAlloc = repeat(infotem.helpers.azero, infotem.pools.carbon.nZix.cEco);

	## pack land variables
	@pack_land cAlloc => land.cAllocation
	return land
end

function compute(o::cAllocation_GSI, forcing, land, infotem)

	## unpack land variables
	@unpack_land cAlloc ∈ land.cAllocation

	## unpack land variables
	@unpack_land begin
		fW ∈ land.cAllocationSoilW
		fT ∈ land.cAllocationSoilT
	end
	p_cpNames = [:cVegRoot, :cVegWood, :cVegLeaf]
	p_zixVecs = [
	infotem.pools.carbon.zix.cVegRoot
	infotem.pools.carbon.zix.cVegWood
	infotem.pools.carbon.zix.cVegLeaf
	]
	# allocation to root; wood & leaf
	cf2.cVegLeaf = fW / (fW + fT) / 2
	cf2.cVegWood = fW / (fW + fT) / 2
	cf2.cVegRoot = fT / (fW + fT)
	# distribute the allocation according to pools
	# cpNames = (:cVegRoot, :cVegWood, :cVegLeaf)
	for cpN in 1:length(p_cpNames)
		cpName = p_cpNames[cpN]
		zixVec = p_zixVecs[cpN]
		N = length(zixVec)
		for zix in zixVec
			cAlloc[zix] = cf2.(cpName) / N
		end
	end
	# cpNames = [:cVegRoot, :cVegWood, :cVegLeaf]
	# for cpName = cpNames
	# zixVec = infotem.pools.carbon.zix.(cpName)
	# N = length(zixVec)
	# for zix = zixVec
	# cAlloc[zix] = cf2.(cpName) / N
	# end
	# end

	## pack land variables
	@pack_land begin
		(p_cpNames, p_zixVecs) => land.cAllocation
		cAlloc => land.states
	end
	return land
end

@doc """
compute the fraction of NPP that is allocated to the different plant organs. In this case; the allocation is dynamic in time according to temperature; water & radiation stressors computed from GSI approach.

---

# compute:
Combine the different effects of carbon allocation using cAllocation_GSI

*Inputs*
 - land.cAllocationRadiation.fR: radiation stressors for carbo allocation
 - land.cAllocationSoilW.fT: temperature stressors for carbon allocation
 - land.cAllocationSoilW.fW: water stressors for carbon allocation

*Outputs*
 - land.states.cAlloc: the fraction of NPP that is allocated to the different plant organs
 - land.states.cAlloc

# precompute:
precompute/instantiate time-invariant variables for cAllocation_GSI


---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard

Notes:  Check if we can partition C to leaf & wood constrained by interception of light.
"""
cAllocation_GSI