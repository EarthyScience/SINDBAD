export snowFraction_binary, snowFraction_binary_h
"""
compute the snow pack & fraction of snow cover.

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct snowFraction_binary{T} <: snowFraction
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::snowFraction_binary, forcing, land, infotem)
	# @unpack_snowFraction_binary o
	return land
end

function compute(o::snowFraction_binary, forcing, land, infotem)
	@unpack_snowFraction_binary o

	## unpack variables
	@unpack_land begin
		snowW ∈ land.pools
	end
	# if there is snow; then snow fraction is 1; otherwise 0
	snowFraction = Float64[snowW[1] > 0.0]

	## pack variables
	@pack_land begin
		snowFraction ∋ land.states
	end
	return land
end

function update(o::snowFraction_binary, forcing, land, infotem)
	# @unpack_snowFraction_binary o
	return land
end

"""
compute the snow pack & fraction of snow cover.

# precompute:
precompute/instantiate time-invariant variables for snowFraction_binary

# compute:
Calculate snow cover fraction using snowFraction_binary

*Inputs:*
 - land.rainSnow.snow : snow fall [mm/time]

*Outputs:*
 -

# update
update pools and states in snowFraction_binary
 - land.pools.snowW: updates the snow pack with snow fall
 - land.states.snowFraction: sets snowFraction to 1 if there is snow; to 0 if there  is now snow

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Martin Jung [mjung]
"""
function snowFraction_binary_h end