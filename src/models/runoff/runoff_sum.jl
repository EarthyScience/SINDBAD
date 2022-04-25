export runoff_sum

struct runoff_sum <: runoff
end

function precompute(o::runoff_sum, forcing, land, helpers)

	## set variables to zero
	runoffBase = helpers.numbers.𝟘
	runoffSurface = helpers.numbers.𝟘

	## pack land variables
	@pack_land begin
		(runoffBase, runoffSurface) => land.fluxes
	end
	return land
end

function compute(o::runoff_sum, forcing, land, helpers)

	## unpack land variables
	@unpack_land (runoffBase, runoffSurface) ∈ land.fluxes

	## calculate variables
	runoff = runoffSurface + runoffBase

	## pack land variables
	@pack_land runoff => land.fluxes
	return land
end

@doc """
calculates runoff as a sum of all potential components

---

# compute:
Calculate the total runoff as a sum of components using runoff_sum

*Inputs*
 - land.fluxes.runoffBase
 - land.fluxes.runoffSurface

*Outputs*
 - land.fluxes.runoff

# precompute:
precompute/instantiate time-invariant variables for runoff_sum


---

# Extended help

*References*

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
runoff_sum