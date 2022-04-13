export cAllocationRadiation_none, cAllocationRadiation_none_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationRadiation_none{T} <: cAllocationRadiation
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cAllocationRadiation_none, forcing, land, infotem)
	@unpack_cAllocationRadiation_none o

	## calculate variables
	fR = 1.0

	## pack variables
	@pack_land begin
		fR ∋ land.cAllocationRadiation
	end
	return land
end

function compute(o::cAllocationRadiation_none, forcing, land, infotem)
	# @unpack_cAllocationRadiation_none o
	return land
end

function update(o::cAllocationRadiation_none, forcing, land, infotem)
	# @unpack_cAllocationRadiation_none o
	return land
end

"""
# Extended help
"""
function cAllocationRadiation_none_h end