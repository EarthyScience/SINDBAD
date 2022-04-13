export runoffOverland_Inf, runoffOverland_Inf_h
"""
calculates total overland runoff that passes to the surface storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffOverland_Inf{T} <: runoffOverland
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffOverland_Inf, forcing, land, infotem)
	# @unpack_runoffOverland_Inf o
	return land
end

function compute(o::runoffOverland_Inf, forcing, land, infotem)
	@unpack_runoffOverland_Inf o

	## unpack variables
	@unpack_land begin
		roInf ∈ land.fluxes
	end
	runoffOverland = roInf

	## pack variables
	@pack_land begin
		runoffOverland ∋ land.fluxes
	end
	return land
end

function update(o::runoffOverland_Inf, forcing, land, infotem)
	# @unpack_runoffOverland_Inf o
	return land
end

"""
calculates total overland runoff that passes to the surface storage

# precompute:
precompute/instantiate time-invariant variables for runoffOverland_Inf

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Inf

*Inputs:*
 - land.fluxes.roInf: infiltration excess runoff

*Outputs:*
 - land.fluxes.runoffOverland : runoff over land [mm/time]

# update
update pools and states in runoffOverland_Inf

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffOverland_Inf_h end