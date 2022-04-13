export WUE_constant, WUE_constant_h
"""
calculates the WUE/AOE as a constant in space & time

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct WUE_constant{T1} <: WUE
	constantWUE::T1 = 4.1 | (1.0, 10.0) | "mean FluxNet WUE" | "gC/mmH2O"
end

function precompute(o::WUE_constant, forcing, land, infotem)
	@unpack_WUE_constant o

	## calculate variables
	AoE = constantWUE

	## pack variables
	@pack_land begin
		AoE ∋ land.WUE
	end
	return land
end

function compute(o::WUE_constant, forcing, land, infotem)
	# @unpack_WUE_constant o
	return land
end

function update(o::WUE_constant, forcing, land, infotem)
	# @unpack_WUE_constant o
	return land
end

"""
calculates the WUE/AOE as a constant in space & time

# precompute:
precompute/instantiate time-invariant variables for WUE_constant

# compute:
Estimate wue using WUE_constant

*Inputs:*

*Outputs:*
 - land.WUE.AoE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

# update
update pools and states in WUE_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUE across fluxNet  sites
 - Sujan Koirala [skoirala]
"""
function WUE_constant_h end