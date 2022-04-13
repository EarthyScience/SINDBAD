export transpiration_coupled, transpiration_coupled_h
"""
calculate the actual transpiration as function of gppAct & WUE

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpiration_coupled{T} <: transpiration
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpiration_coupled, forcing, land, infotem)
	# @unpack_transpiration_coupled o
	return land
end

function compute(o::transpiration_coupled, forcing, land, infotem)
	@unpack_transpiration_coupled o

	## unpack variables
	@unpack_land begin
		gpp ∈ land.fluxes
		AoE ∈ land.WUE
	end
	#--> calculate actual transpiration coupled with GPP
	transpiration = gpp / AoE

	## pack variables
	@pack_land begin
		transpiration ∋ land.fluxes
	end
	return land
end

function update(o::transpiration_coupled, forcing, land, infotem)
	# @unpack_transpiration_coupled o
	return land
end

"""
calculate the actual transpiration as function of gppAct & WUE

# precompute:
precompute/instantiate time-invariant variables for transpiration_coupled

# compute:
If coupled, computed from gpp and aoe from wue using transpiration_coupled

*Inputs:*
 - land.WUE.AoE: water use efficiency in gC/mmH2O
 - land.fluxes.gppAct: GPP based on a minimum of demand & stressors (except water  limitation) out of gppAct_coupled in which tranSup is used to get  supply limited GPP

*Outputs:*
 - land.fluxes.transpiration: actual transpiration

# update
update pools and states in transpiration_coupled
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Martin Jung [mjung]
 - Sujan Koirala [skoirala]

*Notes:*
"""
function transpiration_coupled_h end