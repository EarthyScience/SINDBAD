export gppAirT_MOD17, gppAirT_MOD17_h
"""
calculate the temperature stress on gppPot based on GPP - MOD17 model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_MOD17{T1, T2} <: gppAirT
	Tmax::T1 = 20.0 | (10.0, 35.0) | "temperature for max GPP" | "°C"
	Tmin::T2 = 5.0 | (0.0, 15.0) | "temperature for min GPP" | "°C"
end

function precompute(o::gppAirT_MOD17, forcing, land, infotem)
	# @unpack_gppAirT_MOD17 o
	return land
end

function compute(o::gppAirT_MOD17, forcing, land, infotem)
	@unpack_gppAirT_MOD17 o

	## unpack variables
	@unpack_land begin
		TairDay ∈ forcing
	end
	tmp = 1.0
	td = (Tmax - Tmin) * tmp
	tmax = Tmax * tmp
	tsc = TairDay / td + 1 - tmax / td
	tsc[tsc < 0.0] = 0.0
	tsc[tsc > 1] = 1
	TempScGPP = tsc

	## pack variables
	@pack_land begin
		TempScGPP ∋ land.gppAirT
	end
	return land
end

function update(o::gppAirT_MOD17, forcing, land, infotem)
	# @unpack_gppAirT_MOD17 o
	return land
end

"""
calculate the temperature stress on gppPot based on GPP - MOD17 model

# precompute:
precompute/instantiate time-invariant variables for gppAirT_MOD17

# compute:
Effect of temperature using gppAirT_MOD17

*Inputs:*
 - forcing.TairDay: daytime temperature [°C]

*Outputs:*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

# update
update pools and states in gppAirT_MOD17
 -

# Extended help

*References:*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of global terrestrial  primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005). Improvements  of the MODIS terrestrial gross & net primary production global data set. Remote  sensing of Environment, 95[2], 164-176.

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
"""
function gppAirT_MOD17_h end