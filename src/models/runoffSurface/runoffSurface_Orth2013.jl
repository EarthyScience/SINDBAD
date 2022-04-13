export runoffSurface_Orth2013, runoffSurface_Orth2013_h
"""
calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSurface_Orth2013{T1} <: runoffSurface
	qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time"
end

function precompute(o::runoffSurface_Orth2013, forcing, land, infotem)
	@unpack_runoffSurface_Orth2013 o

	## instantiate variables
	z = exp(-((0:60) / (qt * ones(1, 61)))) - exp((((0:60)+1) / (qt * ones(1, 61))))
	Rdelay = z / (sum(z) * ones(1, 61))

	## pack variables
	@pack_land begin
		(z, Rdelay) ∋ land.runoffSurface
	end
	return land
end

function compute(o::runoffSurface_Orth2013, forcing, land, infotem)
	@unpack_runoffSurface_Orth2013 o

	## unpack variables
	@unpack_land begin
		(z, Rdelay) ∈ land.runoffSurface
		surfaceW ∈ land.pools
		runoffOverland ∈ land.fluxes
	end
	#--> calculate delay function of previous days
	# calculate Q from delay of previous days
	if tix > 60
		tmin = maximum(tix-60, 1)
		runoffSurface = sum(runoffOverland[tmin:tix] * Rdelay)
	else # | accumulate land runoff in surface storage
		runoffSurface = 0.0
	end
	# update the water pool

	## pack variables
	@pack_land begin
		runoffSurface ∋ land.fluxes
		Rdelay ∋ land.runoffSurface
	end
	return land
end

function update(o::runoffSurface_Orth2013, forcing, land, infotem)
	@unpack_runoffSurface_Orth2013 o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		(runoffOverland, runoffSurface) ∈ land.fluxes
	end

	## update variables
	surfaceW[1] = surfaceW[1] + runoffOverland - runoffSurface

	## pack variables
	@pack_land begin
		surfaceW ∋ land.pools
	end
	return land
end

"""
calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff

# precompute:
precompute/instantiate time-invariant variables for runoffSurface_Orth2013

# compute:
Runoff from surface water storages using runoffSurface_Orth2013

*Inputs:*

*Outputs:*
 - land.fluxes.runoffSurface : runoff from land [mm/time]
 - land.runoffSurface.Rdelay

# update
update pools and states in runoffSurface_Orth2013

# Extended help

*References:*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by:*
 - Tina Trautmann [ttraut]

*Notes:*
 - how to handle 60days?!?!
"""
function runoffSurface_Orth2013_h end