export runoffInfiltrationExcess_none, runoffInfiltrationExcess_none_h
"""
sets infiltration excess runoff to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffInfiltrationExcess_none{T} <: runoffInfiltrationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffInfiltrationExcess_none, forcing, land, infotem)
	@unpack_runoffInfiltrationExcess_none o

	## calculate variables
	roInf = 0.0

	## pack variables
	@pack_land begin
		roInf ∋ land.fluxes
	end
	return land
end

function compute(o::runoffInfiltrationExcess_none, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_none o
	return land
end

function update(o::runoffInfiltrationExcess_none, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_none o
	return land
end

"""
sets infiltration excess runoff to zeros

# Extended help
"""
function runoffInfiltrationExcess_none_h end