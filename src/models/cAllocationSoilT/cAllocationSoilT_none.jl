export cAllocationSoilT_none, cAllocationSoilT_none_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilT_none{T} <: cAllocationSoilT
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationSoilT_none, forcing, land, infotem)
	@unpack_cAllocationSoilT_none o

	## calculate variables
	fT = 1.0; #sujan fsoilW was changed to fTSoil

	## pack variables
	@pack_land begin
		fT ∋ land.cAllocationSoilT
	end
	return land
end

function compute(o::cAllocationSoilT_none, forcing, land, infotem)
	# @unpack_cAllocationSoilT_none o
	return land
end

function update(o::cAllocationSoilT_none, forcing, land, infotem)
	# @unpack_cAllocationSoilT_none o
	return land
end

"""
# Extended help
"""
function cAllocationSoilT_none_h end