export rainIntensity_simple, rainIntensity_simple_h
"""
stores the time series of rainfall intensity

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rainIntensity_simple{T1} <: rainIntensity
	rainIntFactor::T1 = 0.04167 | (0.0, 1.0) | "factor to convert daily rainfall to rainfall intensity" | ""
end

function precompute(o::rainIntensity_simple, forcing, land, infotem)
	# @unpack_rainIntensity_simple o
	return land
end

function compute(o::rainIntensity_simple, forcing, land, infotem)
	@unpack_rainIntensity_simple o

	## unpack variables
	@unpack_land begin
		Rain ∈ forcing
	end
	rainInt = Rain * rainIntFactor

	## pack variables
	@pack_land begin
		rainInt ∋ land.rainIntensity
	end
	return land
end

function update(o::rainIntensity_simple, forcing, land, infotem)
	# @unpack_rainIntensity_simple o
	return land
end

"""
stores the time series of rainfall intensity

# precompute:
precompute/instantiate time-invariant variables for rainIntensity_simple

# compute:
Set rainfall intensity using rainIntensity_simple

*Inputs:*
 - forcing.Rain

*Outputs:*
 - land.rainIntensity.rainInt: Intesity of rainfall during the day

# update
update pools and states in rainIntensity_simple
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function rainIntensity_simple_h end