export cAllocationSoilW_none, cAllocationSoilW_none_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilW_none{T} <: cAllocationSoilW
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationSoilW_none, forcing, land, infotem)
	@unpack_cAllocationSoilW_none o

	## calculate variables
	fW = 1.0

	## pack variables
	@pack_land begin
		fW ∋ land.cAllocationSoilW
	end
	return land
end

function compute(o::cAllocationSoilW_none, forcing, land, infotem)
	# @unpack_cAllocationSoilW_none o
	return land
end

function update(o::cAllocationSoilW_none, forcing, land, infotem)
	# @unpack_cAllocationSoilW_none o
	return land
end

"""
# Extended help
"""
function cAllocationSoilW_none_h end