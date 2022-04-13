export snowFraction_HTESSEL, snowFraction_HTESSEL_h
"""
computes the snow pack & fraction of snow cover following the HTESSEL approach

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct snowFraction_HTESSEL{T1} <: snowFraction
	CoverParam::T1 = 15.0 | (1.0, 100.0) | "Snow Cover Parameter" | "mm"
end

function precompute(o::snowFraction_HTESSEL, forcing, land, infotem)
	# @unpack_snowFraction_HTESSEL o
	return land
end

function compute(o::snowFraction_HTESSEL, forcing, land, infotem)
	@unpack_snowFraction_HTESSEL o

	## unpack variables
	@unpack_land begin
		snowW ∈ land.pools
	end
	# suggested by Sujan [after HTESSEL GHM]
	snowFraction = min(1.0, snowW[1] / CoverParam)

	## pack variables
	@pack_land begin
		snowFraction ∋ land.states
	end
	return land
end

function update(o::snowFraction_HTESSEL, forcing, land, infotem)
	# @unpack_snowFraction_HTESSEL o
	return land
end

"""
computes the snow pack & fraction of snow cover following the HTESSEL approach

# precompute:
precompute/instantiate time-invariant variables for snowFraction_HTESSEL

# compute:
Calculate snow cover fraction using snowFraction_HTESSEL

*Inputs:*
 - land.rainSnow.snow: snowfall

*Outputs:*
 - land.fluxes.evaporation: soil evaporation flux

# update
update pools and states in snowFraction_HTESSEL
 - land.pools.snowW: adds snow fall to the snow pack
 - land.states.snowFraction: updates snow cover fraction

# Extended help

*References:*
 - H-TESSEL = land surface scheme of the European Centre for Medium-  Range Weather Forecasts" operational weather forecast system  Balsamo et al.; 2009

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Martin Jung [mjung]
"""
function snowFraction_HTESSEL_h end