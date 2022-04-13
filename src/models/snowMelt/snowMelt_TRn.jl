export snowMelt_TRn, snowMelt_TRn_h
"""
precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0°C. precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0 °C

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct snowMelt_TRn{T1, T2} <: snowMelt
	melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
	melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m2"
end

function precompute(o::snowMelt_TRn, forcing, land, infotem)
	@unpack_snowMelt_TRn o

	## instantiate variables
	potMelt = zeros(size(Tair))

	## pack variables
	@pack_land begin
		potMelt ∋ land.snowMelt
	end
	return land
end

function compute(o::snowMelt_TRn, forcing, land, infotem)
	@unpack_snowMelt_TRn o

	## unpack variables
	@unpack_land begin
		potMelt ∈ land.snowMelt
		(Rn, Tair) ∈ forcing
		(WBP, snowFraction) ∈ land.states
		snowW ∈ land.pools
	end
	# potential snow melt if T > 0.0 deg C
	idx = Tair > 0.0
	tmp_mt = melt_T
	tmp_T = Tair[idx] * tmp_mt[idx]
	tmp_mr = melt_Rn
	tmp_Rn = max(Rn[idx] * tmp_mr[idx], 0)
	potMelt[idx] = tmp_T + tmp_Rn
	# Then snow melt [mm/day] is calculated as a simple function of temperature & radiation
	# & scaled with the snow covered fraction
	snowMelt = min(snowW[1] , potMelt * snowFraction)
	# a Water Balance Pool variable that tracks how much water is still
	# "available"
	WBP = WBP + snowMelt

	## pack variables
	@pack_land begin
		snowMelt ∋ land.fluxes
		potMelt ∋ land.snowMelt
		WBP ∋ land.states
	end
	return land
end

function update(o::snowMelt_TRn, forcing, land, infotem)
	@unpack_snowMelt_TRn o

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
precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0°C. precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0 °C

# precompute:
precompute/instantiate time-invariant variables for snowMelt_TRn

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_TRn

*Inputs:*
 - forcing.Rn: net radiation [MJ/m2/day]
 - forcing.Tair: temperature [C]
 - info structure
 - land.snowMelt.potMelt : potential snow melt based on temperature & net radiation [mm/time]
 - land.states.snowFraction : snow cover fraction []

*Outputs:*
 - land.fluxes.snowMelt : snow melt [mm/time]
 - land.snowMelt.potMelt: potential snow melt [mm/time]

# update
update pools and states in snowMelt_TRn
 -
 - land.pools.snowW[1] : snowpack [mm]
 - land.states.WBP : water balance pool [mm]

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function snowMelt_TRn_h end