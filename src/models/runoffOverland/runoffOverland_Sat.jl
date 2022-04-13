export runoffOverland_Sat, runoffOverland_Sat_h
"""
calculates total overland runoff that passes to the surface storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffOverland_Sat{T} <: runoffOverland
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffOverland_Sat, forcing, land, infotem)
	# @unpack_runoffOverland_Sat o
	return land
end

function compute(o::runoffOverland_Sat, forcing, land, infotem)
	@unpack_runoffOverland_Sat o

	## unpack variables
	@unpack_land begin
		roSat ∈ land.fluxes
	end
	runoffOverland = roSat

	## pack variables
	@pack_land begin
		runoffOverland ∋ land.fluxes
	end
	return land
end

function update(o::runoffOverland_Sat, forcing, land, infotem)
	# @unpack_runoffOverland_Sat o
	return land
end

"""
calculates total overland runoff that passes to the surface storage

# precompute:
precompute/instantiate time-invariant variables for runoffOverland_Sat

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_Sat

*Inputs:*
 - land.fluxes.roSat: saturation excess runoff

*Outputs:*
 - land.fluxes.runoffOverland : runoff over land [mm/time]

# update
update pools and states in runoffOverland_Sat

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffOverland_Sat_h end