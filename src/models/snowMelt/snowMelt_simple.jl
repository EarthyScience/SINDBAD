export snowMelt_simple, snowMelt_simple_h
"""
precomputes the snow melt term as function of forcing.Tair. computes the snow melt term as function of forcing.Tair

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct snowMelt_simple{T1} <: snowMelt
	rate::T1 = 1.0 | (0.1, 10.0) | "snow melt rate" | "mm/°C"
end

function precompute(o::snowMelt_simple, forcing, land, infotem)
	# @unpack_snowMelt_simple o
	return land
end

function compute(o::snowMelt_simple, forcing, land, infotem)
	@unpack_snowMelt_simple o

	## unpack variables
	@unpack_land begin
		Tair ∈ forcing
		(WBP, snowFraction) ∈ land.states
		snowW ∈ land.pools
	end
	# effect of temperature on snow melt = snowMeltRate * Tair
	pRate = (rate * infotem.dates.nStepsDay)
	Tterm = max(pRate * Tair, 0.0)
	# snow melt [mm/day] is calculated as a simple function of temperature
	# & scaled with the snow covered fraction
	snowMelt = min(snowW[1] , Tterm * snowFraction)
	# a Water Balance Pool variable that tracks how much water is still
	# "available"
	WBP = WBP + snowMelt

	## pack variables
	@pack_land begin
		snowMelt ∋ land.fluxes
		Tterm ∋ land.snowMelt
		WBP ∋ land.states
	end
	return land
end

function update(o::snowMelt_simple, forcing, land, infotem)
	@unpack_snowMelt_simple o

	## unpack variables
	@unpack_land begin
		snowW ∈ land.pools
		snowMelt ∈ land.fluxes
	end

	## update variables
	# update snow pack
	snowW[1] = snowW[1] - snowMelt

	## pack variables
	@pack_land begin
		snowW ∋ land.pools
	end
	return land
end

"""
precomputes the snow melt term as function of forcing.Tair. computes the snow melt term as function of forcing.Tair

# precompute:
precompute/instantiate time-invariant variables for snowMelt_simple

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_simple

*Inputs:*
 - forcing.Tair: temperature [C]
 - infotem.dates.nStepsDay: model time steps per day
 - land.snowMelt.Tterm: effect of temperature on snow melt [mm/time]
 - land.states.snowFraction: snow cover fraction [-]

*Outputs:*
 - land.fluxes.snowMelt: snow melt [mm/time]

# update
update pools and states in snowMelt_simple
 -
 - land.pools.snowW: water storage [mm]
 - land.states.WBP: water balance pool [mm]

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Martin Jung [mjung]

*Notes:*
 - may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.
 - may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.  
"""
function snowMelt_simple_h end