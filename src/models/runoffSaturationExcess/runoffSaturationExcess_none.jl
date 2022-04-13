export runoffSaturationExcess_none, runoffSaturationExcess_none_h
"""
set the saturation excess runoff to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSaturationExcess_none{T} <: runoffSaturationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffSaturationExcess_none, forcing, land, infotem)
	@unpack_runoffSaturationExcess_none o

	## calculate variables
	roSat = 0.0

	## pack variables
	@pack_land begin
		roSat ∋ land.fluxes
	end
	return land
end

function compute(o::runoffSaturationExcess_none, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_none o
	return land
end

function update(o::runoffSaturationExcess_none, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_none o
	return land
end

"""
set the saturation excess runoff to zeros

# Extended help
"""
function runoffSaturationExcess_none_h end