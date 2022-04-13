export runoffInfiltrationExcess_kUnsat, runoffInfiltrationExcess_kUnsat_h
"""
calculates the infiltration excess runoff based on unsτrated hydraulic conductivity

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffInfiltrationExcess_kUnsat{T} <: runoffInfiltrationExcess
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::runoffInfiltrationExcess_kUnsat, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_kUnsat o
	return land
end

function compute(o::runoffInfiltrationExcess_kUnsat, forcing, land, infotem)
	@unpack_runoffInfiltrationExcess_kUnsat o

	## unpack variables
	@unpack_land begin
		WBP ∈ land.states
		kUnsatFuncH ∈ land.soilProperties
	end
	#--> get the unsaturared hydraulic conductivity based on soil properties for the first soil layer
	k_unsat = feval(kUnsatFuncH, s, p, info, 1)
	#--> minimum of the conductivity & the incoming water
	roInf = max(WBP-k_unsat, 0.0)
	#--> update remaining water
	WBP = WBP - roInf

	## pack variables
	@pack_land begin
		roInf ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::runoffInfiltrationExcess_kUnsat, forcing, land, infotem)
	# @unpack_runoffInfiltrationExcess_kUnsat o
	return land
end

"""
calculates the infiltration excess runoff based on unsτrated hydraulic conductivity

# precompute:
precompute/instantiate time-invariant variables for runoffInfiltrationExcess_kUnsat

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_kUnsat

*Inputs:*
 - land.p.soilProperties.kUnsatFuncH: function to calculate unsaturated K: out of pSoil [Saxtion1986 | Saxton2006] end
 - land.pools.soilW of first layer

*Outputs:*
 - land.evaporation.PETSoil
 - land.fluxes.evaporation

# update
update pools and states in runoffInfiltrationExcess_kUnsat
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 23.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function runoffInfiltrationExcess_kUnsat_h end