export fAPAR_LAI, fAPAR_LAI_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct fAPAR_LAI{T} <: fAPAR
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::fAPAR_LAI, forcing, land, infotem)
	# @unpack_fAPAR_LAI o
	return land
end

function compute(o::fAPAR_LAI, forcing, land, infotem)
	@unpack_fAPAR_LAI o

	## unpack variables

	## calculate variables

	## pack variables
	return land
end

function update(o::fAPAR_LAI, forcing, land, infotem)
	# @unpack_fAPAR_LAI o
	return land
end

"""
# Extended help
"""
function fAPAR_LAI_h end