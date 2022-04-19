export rainSnow_forcing

@bounds @describe @units @with_kw struct rainSnow_forcing{T1} <: rainSnow
	SF_scale::T1 = 1.0 | (0.0, 3.0) | "scaling factor for snow fall" | ""
end

function compute(o::rainSnow_forcing, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_rainSnow_forcing o
	@unpack_forcing (Rain, Snow) ∈ forcing

	## unpack land variables
	@unpack_land snowW ∈ land.pools

	## calculate variables
	rain = Rain
	snow = Snow * (SF_scale)
	precip = rain + snow

	## pack land variables
	@pack_land begin
		(precip, rain, snow) => land.rainSnow
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

	## pack land variables
	@pack_land snowW => land.pools
	return land
end

@doc """
stores the time series of rainfall and snowfall from forcing & scale snowfall if SF_scale parameter is optimized

# Parameters
$(PARAMFIELDS)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_forcing

*Inputs*
 - forcing.Rain
 - forcing.Snow
 - info

*Outputs*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: snowfall estimated as the rain when tair <  threshold

# update

update pools and states in rainSnow_forcing

 - forcing.Snow using the snowfall scaling parameter which can be optimized

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_forcing