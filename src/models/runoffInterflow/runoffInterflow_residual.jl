export runoffInterflow_residual

@bounds @describe @units @with_kw struct runoffInterflow_residual{T1} <: runoffInterflow
	rc::T1 = 0.3 | (0.0, 0.9) | "fraction of the available water that flows out as interflow" | ""
end

function compute(o::runoffInterflow_residual, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffInterflow_residual o

	## unpack land variables
	@unpack_land WBP ∈ land.states


	## calculate variables
	# simply assume that a fraction of the still available water runs off
	runoffInterflow = rc * WBP
	# update the WBP
	WBP = WBP - runoffInterflow

	## pack land variables
	@pack_land begin
		runoffInterflow => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
interflow as a fraction of the available water balance pool

# Parameters
$(PARAMFIELDS)

---

# compute:
Interflow using runoffInterflow_residual

*Inputs*

*Outputs*
 - land.fluxes.runoffInterflow: interflow [mm/time]
 - land.states.WBP: water balance pool [mm]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
runoffInterflow_residual