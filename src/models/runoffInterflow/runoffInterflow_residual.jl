export runoffInterflow_residual, runoffInterflow_residual_h
"""
calculates interflow as a fraction of the available water

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffInterflow_residual{T1} <: runoffInterflow
	rc::T1 = 0.3 | (0.0, 0.9) | "simply assume that a fraction of the still available water runs off" | ""
end

function precompute(o::runoffInterflow_residual, forcing, land, infotem)
	# @unpack_runoffInterflow_residual o
	return land
end

function compute(o::runoffInterflow_residual, forcing, land, infotem)
	@unpack_runoffInterflow_residual o

	## unpack variables
	@unpack_land begin
		WBP ∈ land.states
	end
	# simply assume that a fraction of the still available water runs off
	roInt = rc * WBP
	# update the WBP
	WBP = WBP - roInt

	## pack variables
	@pack_land begin
		roInt ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::runoffInterflow_residual, forcing, land, infotem)
	# @unpack_runoffInterflow_residual o
	return land
end

"""
calculates interflow as a fraction of the available water

# precompute:
precompute/instantiate time-invariant variables for runoffInterflow_residual

# compute:
Interflow using runoffInterflow_residual

*Inputs:*

*Outputs:*
 - land.fluxes.roInt: interflow [mm/time]

# update
update pools and states in runoffInterflow_residual
 - land.states.WBP: water balance pool [mm]

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - Martin Jung [mjung]
"""
function runoffInterflow_residual_h end