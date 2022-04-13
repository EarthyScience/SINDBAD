export gppAirT_Wang2014, gppAirT_Wang2014_h
"""
calculate the temperature stress on gppPot based on Wang2014

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_Wang2014{T1} <: gppAirT
	Tmax::T1 = 10.0 | (5.0, 35.0) | "?? Check with martin" | "°C"
end

function precompute(o::gppAirT_Wang2014, forcing, land, infotem)
	# @unpack_gppAirT_Wang2014 o
	return land
end

function compute(o::gppAirT_Wang2014, forcing, land, infotem)
	@unpack_gppAirT_Wang2014 o

	## unpack variables
	@unpack_land begin
		TairDay ∈ forcing
	end
	pTmax = Tmax
	tsc = TairDay / pTmax
	tsc[tsc < 0.0] = 0.0
	tsc[tsc > 1] = 1
	TempScGPP = tsc

	## pack variables
	@pack_land begin
		TempScGPP ∋ land.gppAirT
	end
	return land
end

function update(o::gppAirT_Wang2014, forcing, land, infotem)
	# @unpack_gppAirT_Wang2014 o
	return land
end

"""
calculate the temperature stress on gppPot based on Wang2014

# precompute:
precompute/instantiate time-invariant variables for gppAirT_Wang2014

# compute:
Effect of temperature using gppAirT_Wang2014

*Inputs:*
 - forcing.TairDay: daytime temperature [°C]

*Outputs:*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

# update
update pools and states in gppAirT_Wang2014
 -

# Extended help

*References:*
 - Wang, H., Prentice, I. C., & Davis, T. W. (2014). Biophsyical constraints on gross  primary production by the terrestrial biosphere. Biogeosciences, 11[20], 5987.

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]
"""
function gppAirT_Wang2014_h end