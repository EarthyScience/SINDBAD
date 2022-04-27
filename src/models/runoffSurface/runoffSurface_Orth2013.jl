export runoffSurface_Orth2013

@bounds @describe @units @with_kw struct runoffSurface_Orth2013{T1} <: runoffSurface
	qt::T1 = 2.0 | (0.5, 100.0) | "delay parameter for land runoff" | "time"
end

function precompute(o::runoffSurface_Orth2013, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_runoffSurface_Orth2013 o

	## instantiate variables
	z = exp(-((0:60) / (qt * ones(1, 61)))) - exp((((0:60)+1) / (qt * ones(1, 61))))
	Rdelay = z / (sum(z) * ones(1, 61))

	## pack land variables
	@pack_land (z, Rdelay) => land.runoffSurface
	return land
end

function compute(o::runoffSurface_Orth2013, forcing, land::NamedTuple, helpers::NamedTuple)
	#@needscheck and redo
	## unpack parameters
	@unpack_runoffSurface_Orth2013 o

	## unpack land variables
	@unpack_land (z, Rdelay) ∈ land.runoffSurface

	## unpack land variables
	@unpack_land begin
		surfaceW ∈ land.pools
		runoffOverland ∈ land.fluxes
	end
	# calculate delay function of previous days
	# calculate Q from delay of previous days
	if tix > 60
		tmin = maximum(tix-60, 1)
		runoffSurface = sum(runoffOverland[tmin:tix] * Rdelay)
	else # | accumulate land runoff in surface storage
		runoffSurface = 0.0
	end
	# update the water pool

	## pack land variables
	@pack_land begin
		runoffSurface => land.fluxes
		Rdelay => land.runoffSurface
	end
	return land
end

function update(o::runoffSurface_Orth2013, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_runoffSurface_Orth2013 o

	## unpack variables
	@unpack_land begin
		surfaceW ∈ land.pools
		ΔsurfaceW ∈ land.states
	end

	## update storage pools
	surfaceW .= surfaceW .+ ΔsurfaceW

	# reset ΔsurfaceW to zero
	ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

	## pack land variables
	@pack_land begin
		surfaceW => land.pools
		ΔsurfaceW => land.states
	end
	return land
end

@doc """
calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff

# Parameters
$(PARAMFIELDS)

---

# compute:
Runoff from surface water storages using runoffSurface_Orth2013

*Inputs*

*Outputs*
 - land.fluxes.runoffSurface : runoff from land [mm/time]
 - land.runoffSurface.Rdelay

# update

update pools and states in runoffSurface_Orth2013


# precompute:
precompute/instantiate time-invariant variables for runoffSurface_Orth2013


---

# Extended help

*References*
 - Orth, R., Koster, R. D., & Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
 - used in Trautmann et al. 2018

*Versions*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by:*
 - ttraut

*Notes*
 - how to handle 60days?!?!
"""
runoffSurface_Orth2013