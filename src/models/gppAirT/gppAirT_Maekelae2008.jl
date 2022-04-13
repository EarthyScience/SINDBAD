export gppAirT_Maekelae2008, gppAirT_Maekelae2008_h
"""
calculate the temperature stress on gppPot based on Maekelae2008 [eqn 3 & 4]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_Maekelae2008{T1, T2, T3} <: gppAirT
	TimConst::T1 = 5.0 | (1.0, 20.0) | "time constant for temp delay" | "days"
	X0::T2 = -5.0 | (-15.0, 1.0) | "threshold of delay temperature" | "°C"
	Smax::T3 = 20.0 | (10.0, 30.0) | "temperature at saturation" | "°C"
end

function precompute(o::gppAirT_Maekelae2008, forcing, land, infotem)
	# @unpack_gppAirT_Maekelae2008 o
	return land
end

function compute(o::gppAirT_Maekelae2008, forcing, land, infotem)
	@unpack_gppAirT_Maekelae2008 o

	## unpack variables
	@unpack_land begin
		TairDay ∈ forcing
	end
	#--> create the arrays
	tmp = 1.0
	X0 = X0 * tmp
	Smax = Smax * tmp
	#--> calculate temperature acclimation
	X = TairDay; #pix;tix
	for ii in 2:info.tem.helpers.sizes.nTix
		X[ii] = X[ii-1] + (1 / TimConst) * (TairDay[ii] - X[ii-1])
	end
	#--> calculate the stress & saturation
	S = max(X - X0 , 0.0)
	vsc = max(min(S / Smax, 1), 0.0)
	#--> assign stressor
	TempScGPP = vsc

	## pack variables
	@pack_land begin
		TempScGPP ∋ land.gppAirT
	end
	return land
end

function update(o::gppAirT_Maekelae2008, forcing, land, infotem)
	# @unpack_gppAirT_Maekelae2008 o
	return land
end

"""
calculate the temperature stress on gppPot based on Maekelae2008 [eqn 3 & 4]

# precompute:
precompute/instantiate time-invariant variables for gppAirT_Maekelae2008

# compute:
Effect of temperature using gppAirT_Maekelae2008

*Inputs:*
 - forcing.TairDay: daytime temperature [°C]

*Outputs:*
 - land.gppDirRadiation.LightScGPP: effect of light saturation on potential GPP

# update
update pools and states in gppAirT_Maekelae2008
 -

# Extended help

*References:*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approach:  analysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - Nuno Carvalhais [ncarval]

*Notes:*
 - Tmin < Tmax ALWAYS!!!
"""
function gppAirT_Maekelae2008_h end