export runoffSurface_Trautmann2018

@bounds @describe @units @with_kw struct runoffSurface_Trautmann2018{T1} <: runoffSurface
	qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time"
end

function precompute(o::runoffSurface_Trautmann2018, forcing, land, helpers)
	@unpack_runoffSurface_Trautmann2018 o

	## instantiate variables
	z = exp(-((0:60) / (qt * ones(1, 61)))) - exp((((0:60)+1) / (qt * ones(1, 61))))
	Rdelay = z / (sum(z) * ones(1, 61))

	## pack land variables
	@pack_land (z, Rdelay) => land.runoffSurface
	return land
end

function compute(o::runoffSurface_Trautmann2018, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSurface_Trautmann2018 o

	## unpack land variables
	@unpack_land (z, Rdelay) ∈ land.runoffSurface

	## unpack land variables
	@unpack_land begin
		(rain, snow) ∈ land.rainSnow
		(snowW, snowW_prev, soilW, soilW_prev, surfaceW) ∈ land.pools
		(evaporation, runoffOverland, sublimation) ∈ land.fluxes
	end
	# calculate delay function of previous days
	# calculate Q from delay of previous days
	if tix > 60
		tmin = maximum(tix-60, 1)
		runoffSurface = sum(runoffOverland[tmin:tix] * Rdelay)
		# calculate surfaceW[1] by water balance
		delSnow = sum(snowW) - sum(snowW_prev)
		input = rain+snow
		loss = evaporation + sublimation + runoffSurface
		delSoil = sum(soilW) - sum(soilW_prev)
		dSurf = input- loss - delSnow - delSoil
	else
		runoffSurface = 0.0
		dSurf = runoffOverland
	end

	## pack land variables
	@pack_land begin
		runoffSurface => land.fluxes
		(Rdelay, dSurf) => land.runoffSurface
	end
	return land
end

function update(o::runoffSurface_Trautmann2018, forcing, land, helpers)
	@unpack_runoffSurface_Trautmann2018 o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		dSurf ∈ land.runoffSurface
	end

	## update variables
	# update surface water pool 
	surfaceW[1] = surfaceW[1] + dSurf; 

	## pack land variables
	@pack_land surfaceW => land.pools
	return land
end

@doc """
calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 & as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 & as it is used in Trautmannet al. 2018

# Parameters
$(PARAMFIELDS)

---

# compute:
Runoff from surface water storages using runoffSurface_Trautmann2018

*Inputs*

*Outputs*
 - land.fluxes.runoffSurface : runoff from land [mm/time]
 - land.runoffSurface.Rdelay

# update

update pools and states in runoffSurface_Trautmann2018


# precompute:
precompute/instantiate time-invariant variables for runoffSurface_Trautmann2018


---

# Extended help

*References*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  
 - 1.1 on 21.01.2020 [ttraut] : calculate surfaceW[1] based on water balance  (1:1 as in TWS Paper)

*Created by:*
 - ttraut

*Notes*
 - how to handle 60days?!?!
"""
runoffSurface_Trautmann2018