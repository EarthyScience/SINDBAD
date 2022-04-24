export totalTWS_sumComponents

struct totalTWS_sumComponents <: totalTWS
end

function precompute(o::totalTWS_sumComponents, forcing, land, helpers)
	@unpack_land numType ∈ helpers.numbers
	## calculate variables
	if !hasproperty(land.pools, :soilW)
		soilW = zeros(numType, length(land.pools.soilW))
	else
		@unpack_land soilW ∈ land.pools
	end

	if !hasproperty(land.pools, :groundW)
		groundW = zeros(numType, helpers.pools.water.nZix.groundW)
	else
		@unpack_land groundW ∈ land.pools
	end
	
	if !hasproperty(land.pools, :surfaceW)
		surfaceW = zeros(numType, helpers.pools.water.nZix.surfaceW)
	else
		@unpack_land surfaceW ∈ land.pools
	end
	
	if !hasproperty(land.pools, :snowW)
		snowW = zeros(numType, helpers.pools.water.nZix.snowW)
	else
		@unpack_land snowW ∈ land.pools
	end
	
	
	## calculate variables
	totalsoilW = sum(soilW)
	totalW = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

	## pack land variables
	@pack_land begin
		(soilW, groundW, surfaceW, snowW) => land.pools
		(totalW, totalsoilW) => land.totalTWS
	end
	return land
end

function compute(o::totalTWS_sumComponents, forcing, land, helpers)

	## unpack land variables
	@unpack_land (groundW, snowW, soilW, surfaceW) ∈ land.pools

	## calculate variables
	totalsoilW = sum(soilW)
	totalW = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

	## pack land variables
	@pack_land (totalW, totalsoilW) => land.totalTWS
	return land
end

@doc """
calculates total water storage as a sum of all potential components

---

# compute:
Calculate the total water storage as a sum of components using totalTWS_sumComponents

*Inputs*
 - land.pools.groundW[1]
 - land.pools.snowW[1]
 - land.pools.soilW
 - land.pools.surfaceW[1]

*Outputs*
 - land.pools.soilW_total: total soil moisture
 - land.pools.wTotal: total water storage

# precompute:
precompute/instantiate time-invariant variables for totalTWS_sumComponents


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
totalTWS_sumComponents