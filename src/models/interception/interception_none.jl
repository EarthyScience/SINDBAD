export interception_none, interception_none_h
"""
sets the interception evaporation to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct interception_none{T} <: interception
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::interception_none, forcing, land, infotem)
	@unpack_interception_none o

	## calculate variables
	interception = 0.0

	## pack variables
	@pack_land begin
		interception ∋ land.fluxes
	end
	return land
end

function compute(o::interception_none, forcing, land, infotem)
	# @unpack_interception_none o
	return land
end

function update(o::interception_none, forcing, land, infotem)
	# @unpack_interception_none o
	return land
end

"""
sets the interception evaporation to zeros

# Extended help
"""
function interception_none_h end