export TWS_sum

struct TWS_sum <: TWS
end

function precompute(o::TWS_sum, forcing, land, infotem)
	@unpack_land azero ∈ infotem.helpers
	## calculate variables
	if !hasproperty(land.pools, :soilW)
		soilW = azero
	else
		@unpack_land soilW ∈ land.pools
	end

	if !hasproperty(land.pools, :groundW)
		groundW = azero
	else
		@unpack_land groundW ∈ land.pools
	end
	
	if !hasproperty(land.pools, :surfaceW)
		surfaceW = azero
	else
		@unpack_land surfaceW ∈ land.pools
	end
	
	if !hasproperty(land.pools, :snowW)
		snowW = azero
	else
		@unpack_land snowW ∈ land.pools
	end
	
	
	## calculate variables
	totalsoilW = sum(soilW)
	totalW = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

	## pack land variables
	@pack_land begin
		(soilW, groundW, surfaceW, snowW) => land.pools
		(totalW, totalsoilW) => land.TWS
	end
	return land
end

function compute(o::TWS_sum, forcing, land, infotem)

	## unpack land variables
	@unpack_land (groundW, snowW, soilW, surfaceW) ∈ land.pools

	## calculate variables
	totalsoilW = sum(soilW)
	totalW = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

	## pack land variables
	@pack_land (totalW, totalsoilW) => land.TWS
	return land
end

@doc """
calculates total water storage as a sum of all potential components

---

# compute:
Calculate the total water storage as a sum of components using TWS_sum

*Inputs*
 - land.pools.groundW[1]
 - land.pools.snowW[1]
 - land.pools.soilW
 - land.pools.surfaceW[1]

*Outputs*
 - land.pools.soilW_total: total soil moisture
 - land.pools.wTotal: total water storage

# precompute:
precompute/instantiate time-invariant variables for TWS_sum


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
TWS_sum