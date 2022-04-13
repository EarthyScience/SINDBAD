export rainIntensity_forcing, rainIntensity_forcing_h
"""
stores the time series of rainfall & snowfall from forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rainIntensity_forcing{T} <: rainIntensity
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::rainIntensity_forcing, forcing, land, infotem)
	# @unpack_rainIntensity_forcing o
	return land
end

function compute(o::rainIntensity_forcing, forcing, land, infotem)
	@unpack_rainIntensity_forcing o

	## unpack variables
	@unpack_land begin
		RainInt ∈ forcing
	end
	rainInt = RainInt

	## pack variables
	@pack_land begin
		rainInt ∋ land.rainIntensity
	end
	return land
end

function update(o::rainIntensity_forcing, forcing, land, infotem)
	# @unpack_rainIntensity_forcing o
	return land
end

"""
stores the time series of rainfall & snowfall from forcing

# precompute:
precompute/instantiate time-invariant variables for rainIntensity_forcing

# compute:
Set rainfall intensity using rainIntensity_forcing

*Inputs:*
 - land.rainIntensity.rainInt

*Outputs:*
 - land.rainIntensity.rainInt: liquid rainfall from forcing input  threshold

# update
update pools and states in rainIntensity_forcing
 - forcing.Snow using the snowfall scaling parameter which can be optimized

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function rainIntensity_forcing_h end