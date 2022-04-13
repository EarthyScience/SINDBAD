export rainSnow_forcing, rainSnow_forcing_h
"""
stores the time series of rainfall and snowfall from forcing & scale snowfall if SF_scale parameter is optimized

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rainSnow_forcing{T1} <: rainSnow
	SF_scale::T1 = 1.0 | (0.0, 3.0) | "scaling factor for snow fall" | ""
end

function precompute(o::rainSnow_forcing, forcing, land, infotem)
	# @unpack_rainSnow_forcing o
	return land
end

function compute(o::rainSnow_forcing, forcing, land, infotem)
	@unpack_rainSnow_forcing o

	## unpack variables
	@unpack_land begin
		(Rain, Snow) ∈ forcing
		snowW ∈ land.pools
	end
	rain = Rain
	snow = Snow * (SF_scale); # ones as parameter has one value for each pixelf.Snow
	precip = rain + snow

	## pack variables
	@pack_land begin
		(precip, rain, snow) ∋ land.rainSnow
	end
	return land
end

function update(o::rainSnow_forcing, forcing, land, infotem)
	@unpack_rainSnow_forcing o

	## unpack variables
	@unpack_land begin
		snowW ∈ land.pools
		snow ∈ land.rainSnow
	end

	## update variables
	# update snow pack
	snowW[1] = snowW[1] + snow

	## pack variables
	@pack_land begin
		snowW ∋ land.pools
	end
	return land
end

"""
stores the time series of rainfall and snowfall from forcing & scale snowfall if SF_scale parameter is optimized

# precompute:
precompute/instantiate time-invariant variables for rainSnow_forcing

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_forcing

*Inputs:*
 - forcing.Rain
 - forcing.Snow
 - info

*Outputs:*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: snowfall estimated as the rain when tair <  threshold

# update
update pools and states in rainSnow_forcing
 - forcing.Snow using the snowfall scaling parameter which can be optimized

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function rainSnow_forcing_h end