export gpp_coupled, gpp_coupled_h
"""
calculate GPP based on transpiration supply & water use efficiency [coupled]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gpp_coupled{T} <: gpp
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::gpp_coupled, forcing, land, infotem)
	# @unpack_gpp_coupled o
	return land
end

function compute(o::gpp_coupled, forcing, land, infotem)
	@unpack_gpp_coupled o

	## unpack variables
	@unpack_land begin
		tranSup ∈ land.transpirationSupply
		SMScGPP ∈ land.gppSoilW
		gppE ∈ land.gppDemand
		AoE ∈ land.WUE
	end
	gpp = min(1.0 * tranSup * AoE, gppE * SMScGPP)
	# gpp = min(1.0 * tranSup * AoE, gppE * soilWStress[2])
	# gpp = min(1.0 * tranSup * AoE, gppE * max(soilWStress, [], 2))

	## pack variables
	@pack_land begin
		gpp ∋ land.fluxes
	end
	return land
end

function update(o::gpp_coupled, forcing, land, infotem)
	# @unpack_gpp_coupled o
	return land
end

"""
calculate GPP based on transpiration supply & water use efficiency [coupled]

# precompute:
precompute/instantiate time-invariant variables for gpp_coupled

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_coupled

*Inputs:*
 - land.WUE.AoE: water use efficiency in gC/mmH2O
 - land.gppDemand.gppE: Demand-driven GPP with stressors except soilW applied
 - land.gppSoilW.SMScGPP: soil moisture stress on photosynthetic capacity
 - land.transpirationSupply.tranSup: supply limited transpiration

*Outputs:*
 - land.fluxes.gpp: actual GPP [gC/m2/time]

# update
update pools and states in gpp_coupled
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
function gpp_coupled_h end