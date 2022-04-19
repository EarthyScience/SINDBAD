export cAllocationSoilT_none

struct cAllocationSoilT_none <: cAllocationSoilT
end

function precompute(o::cAllocationSoilT_none, forcing, land, infotem)

	## calculate variables
	fT = infotem.helpers.one; #sujan fsoilW was changed to fTSoil

	## pack land variables
	@pack_land fT => land.cAllocationSoilT
	return land
end

@doc """


# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilT_none


---

# Extended help
"""
cAllocationSoilT_none