export aRespirationAirT_none, aRespirationAirT_none_h
"""
sets the effect of temperature on RA to none [ones = no effect]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct aRespirationAirT_none{T} <: aRespirationAirT
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::aRespirationAirT_none, forcing, land, infotem)
	@unpack_aRespirationAirT_none o

	## calculate variables
	fT = 1.0

	## pack variables
	@pack_land begin
		fT ∋ land.aRespirationAirT
	end
	return land
end

function compute(o::aRespirationAirT_none, forcing, land, infotem)
	# @unpack_aRespirationAirT_none o
	return land
end

function update(o::aRespirationAirT_none, forcing, land, infotem)
	# @unpack_aRespirationAirT_none o
	return land
end

"""
sets the effect of temperature on RA to none [ones = no effect]

# Extended help
"""
function aRespirationAirT_none_h end