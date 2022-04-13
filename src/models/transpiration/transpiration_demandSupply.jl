export transpiration_demandSupply, transpiration_demandSupply_h
"""
calculate the actual transpiration as the minimum of the supply & demand

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct transpiration_demandSupply{T} <: transpiration
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::transpiration_demandSupply, forcing, land, infotem)
	# @unpack_transpiration_demandSupply o
	return land
end

function compute(o::transpiration_demandSupply, forcing, land, infotem)
	@unpack_transpiration_demandSupply o

	## unpack variables
	@unpack_land begin
		tranSup ∈ land.transpirationSupply
		tranDem ∈ land.transpirationDemand
	end
	transpiration = min(tranDem, tranSup)

	## pack variables
	@pack_land begin
		transpiration ∋ land.fluxes
	end
	return land
end

function update(o::transpiration_demandSupply, forcing, land, infotem)
	# @unpack_transpiration_demandSupply o
	return land
end

"""
calculate the actual transpiration as the minimum of the supply & demand

# precompute:
precompute/instantiate time-invariant variables for transpiration_demandSupply

# compute:
If coupled, computed from gpp and aoe from wue using transpiration_demandSupply

*Inputs:*
 - land.transpirationDemand.tranDem: climate demand driven transpiration
 - land.transpirationSupply.tranSup: supply limited transpiration

*Outputs:*
 - land.fluxes.transpiration: actual transpiration

# update
update pools and states in transpiration_demandSupply
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - ignores biological limitation of transpiration demand
"""
function transpiration_demandSupply_h end