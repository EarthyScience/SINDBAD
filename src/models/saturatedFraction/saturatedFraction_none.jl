export saturatedFraction_none, saturatedFraction_none_h
"""
sets the land.states.soilWSatFrac [saturated soil fraction] to zeros (pix, 1)

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct saturatedFraction_none{T} <: saturatedFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::saturatedFraction_none, forcing, land, infotem)
	@unpack_saturatedFraction_none o

	## calculate variables
	soilWSatFrac = 0.0

	## pack variables
	@pack_land begin
		soilWSatFrac ∋ land.states
	end
	return land
end

function compute(o::saturatedFraction_none, forcing, land, infotem)
	# @unpack_saturatedFraction_none o
	return land
end

function update(o::saturatedFraction_none, forcing, land, infotem)
	# @unpack_saturatedFraction_none o
	return land
end

"""
sets the land.states.soilWSatFrac [saturated soil fraction] to zeros (pix, 1)

# Extended help
"""
function saturatedFraction_none_h end