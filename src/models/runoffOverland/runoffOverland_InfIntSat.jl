export runoffOverland_InfIntSat, runoffOverland_InfIntSat_h
"""
calculates total overland runoff that passes to the surface storage

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffOverland_InfIntSat{T} <: runoffOverland
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffOverland_InfIntSat, forcing, land, infotem)
	# @unpack_runoffOverland_InfIntSat o
	return land
end

function compute(o::runoffOverland_InfIntSat, forcing, land, infotem)
	@unpack_runoffOverland_InfIntSat o

	## unpack variables
	@unpack_land begin
		(roInf, roInt, roSat) ∈ land.fluxes
	end
	runoffOverland = roInf + roInt + roSat

	## pack variables
	@pack_land begin
		runoffOverland ∋ land.fluxes
	end
	return land
end

function update(o::runoffOverland_InfIntSat, forcing, land, infotem)
	# @unpack_runoffOverland_InfIntSat o
	return land
end

"""
calculates total overland runoff that passes to the surface storage

# precompute:
precompute/instantiate time-invariant variables for runoffOverland_InfIntSat

# compute:
Land over flow (sum of saturation and infiltration excess runoff) using runoffOverland_InfIntSat

*Inputs:*
 - land.fluxes.roInf: infiltration excess runoff
 - land.fluxes.roInt: intermittent flow
 - land.fluxes.roSat: saturation excess runoff

*Outputs:*
 - land.fluxes.runoffOverland : runoff from land [mm/time]

# update
update pools and states in runoffOverland_InfIntSat

# Extended help

*References:*

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffOverland_InfIntSat_h end