export runoffSaturationExcess_Bergstroem, runoffSaturationExcess_Bergstroem_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem{T} <: runoffSaturationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffSaturationExcess_Bergstroem, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_Bergstroem o
	return land
end

function compute(o::runoffSaturationExcess_Bergstroem, forcing, land, infotem)
	@unpack_runoffSaturationExcess_Bergstroem o

	## unpack variables

	## calculate variables

	## pack variables
	return land
end

function update(o::runoffSaturationExcess_Bergstroem, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_Bergstroem o
	return land
end

"""
# Extended help
"""
function runoffSaturationExcess_Bergstroem_h end