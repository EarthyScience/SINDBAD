export runoff_sum, runoff_sum_h
"""
calculates runoff as a sum of all potential components

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoff_sum{T} <: runoff
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoff_sum, forcing, land, infotem)
	# @unpack_runoff_sum o
	return land
end

function compute(o::runoff_sum, forcing, land, infotem)
	@unpack_runoff_sum o

	## unpack variables
	@unpack_land begin
		(runoffBase, runoffSurface) ∈ land.fluxes
	end
	runoff = runoffSurface + runoffBase

	## pack variables
	@pack_land begin
		runoff ∋ land.fluxes
	end
	return land
end

function update(o::runoff_sum, forcing, land, infotem)
	# @unpack_runoff_sum o
	return land
end

"""
calculates runoff as a sum of all potential components

# precompute:
precompute/instantiate time-invariant variables for runoff_sum

# compute:
Calculate the total runoff as a sum of components using runoff_sum

*Inputs:*
 - land.fluxes.runoffBase
 - land.fluxes.runoffSurface

*Outputs:*
 - land.fluxes.runoff

# update
update pools and states in runoff_sum
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 01.04.2022  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoff_sum_h end