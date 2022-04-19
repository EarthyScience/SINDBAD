export rainSnow_Tair

@bounds @describe @units @with_kw struct rainSnow_Tair{T1} <: rainSnow
	Tair_thres::T1 = 0.0 | (-5.0, 5.0) | "threshold for separating rain and snow" | "°C"
end

function compute(o::rainSnow_Tair, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_rainSnow_Tair o
	@unpack_forcing (Rain, Tair) ∈ forcing

	## unpack land variables
	@unpack_land snowW ∈ land.pools

	## calculate variables
	if Tair < Tair_thres
		snow = Rain
		rain = 0
	else
		rain = Rain
		snow = 0
	end
	precip = rain + snow

	## pack land variables
	@pack_land begin
		(precip, rain, snow) => land.rainSnow
	end
	return land
end

function update(o::rainSnow_Tair, forcing, land, infotem)
	@unpack_rainSnow_Tair o

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
separates the rain & snow based on temperature threshold

# Parameters
$(PARAMFIELDS)

---

# compute:
Set rain and snow to fe.rainsnow. using rainSnow_Tair

*Inputs*
 - forcing.Rain
 - forcing.Tair

*Outputs*
 - land.rainSnow.rain: liquid rainfall from forcing input
 - land.rainSnow.snow: snowfall estimated as the rain when tair <  threshold

# update

update pools and states in rainSnow_Tair


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainSnow_Tair