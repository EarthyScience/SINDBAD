export groundWRecharge_none, groundWRecharge_none_h
"""
set the GW recharge to zeros

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWRecharge_none{T} <: groundWRecharge
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::groundWRecharge_none, forcing, land, infotem)
	@unpack_groundWRecharge_none o

	## calculate variables
	gwRec = 0.0

	## pack variables
	@pack_land begin
		gwRec ∋ land.fluxes
	end
	return land
end

function compute(o::groundWRecharge_none, forcing, land, infotem)
	# @unpack_groundWRecharge_none o
	return land
end

function update(o::groundWRecharge_none, forcing, land, infotem)
	# @unpack_groundWRecharge_none o
	return land
end

"""
set the GW recharge to zeros

# Extended help
"""
function groundWRecharge_none_h end