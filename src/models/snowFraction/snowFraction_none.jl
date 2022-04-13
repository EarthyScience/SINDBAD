export snowFraction_none, snowFraction_none_h
"""
sets the snow fraction to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct snowFraction_none{T} <: snowFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::snowFraction_none, forcing, land, infotem)
	@unpack_snowFraction_none o

	## calculate variables
	snowFraction = 0.0

	## pack variables
	@pack_land begin
		snowFraction ∋ land.states
	end
	return land
end

function compute(o::snowFraction_none, forcing, land, infotem)
	# @unpack_snowFraction_none o
	return land
end

function update(o::snowFraction_none, forcing, land, infotem)
	# @unpack_snowFraction_none o
	return land
end

"""
sets the snow fraction to zeros

# Extended help
"""
function snowFraction_none_h end