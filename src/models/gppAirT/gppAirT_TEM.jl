export gppAirT_TEM, gppAirT_TEM_h
"""
calculate the temperature stress for gppPot based on TEM

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_TEM{T1, T2, T3} <: gppAirT
	Tmin::T1 = 5.0 | (0.0, 15.0) | "?? Check with martin" | "°C"
	Tmax::T2 = 20.0 | (10.0, 35.0) | "?? Check with martin" | "°C"
	Topt::T3 = 15.0 | (5.0, 30.0) | "?? Check with martin" | "°C"
end

function precompute(o::gppAirT_TEM, forcing, land, infotem)
	# @unpack_gppAirT_TEM o
	return land
end

function compute(o::gppAirT_TEM, forcing, land, infotem)
	@unpack_gppAirT_TEM o

	## unpack variables
	@unpack_land begin
		TairDay ∈ forcing
	end
	tmp = 1.0
	pTmin = TairDay - (Tmin * tmp)
	pTmax = TairDay - (Tmax * tmp)
	pTopt = Topt * tmp
	pTScGPP = pTmin * pTmax / ((pTmin * pTmax) - (TairDay - pTopt) ^ 2)
	TempScGPP[TairDay > Tmax] = 0
	TempScGPP[TairDay < Tmin] = 0
	TempScGPP = min(max(pTScGPP, 0.0), 1)

	## pack variables
	@pack_land begin
		TempScGPP ∋ land.gppAirT
	end
	return land
end

function update(o::gppAirT_TEM, forcing, land, infotem)
	# @unpack_gppAirT_TEM o
	return land
end

"""
calculate the temperature stress for gppPot based on TEM

# precompute:
precompute/instantiate time-invariant variables for gppAirT_TEM

# compute:
Effect of temperature using gppAirT_TEM

*Inputs:*
 - forcing.TairDay: daytime temperature [°C]

*Outputs:*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

# update
update pools and states in gppAirT_TEM
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function gppAirT_TEM_h end